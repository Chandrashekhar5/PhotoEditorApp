//
//  ContentView.swift
//  PhotoEditorApp
//
//  Created by Chandu .. on 10/13/24.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    // MARK: - Properties
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    // Core Image context
    let context = CIContext()
    
    // Adjustment properties
    @State private var exposure: Double = 0
    @State private var brilliance: Double = 0
    @State private var highlights: Double = 0
    @State private var shadows: Double = 0
    @State private var contrast: Double = 1
    @State private var brightness: Double = 0
    @State private var blackPoint: Double = 0
    @State private var saturation: Double = 1
    @State private var vibrance: Double = 0
    @State private var warmth: Double = 0
    @State private var tint: Double = 0
    @State private var gradient: Double = 0
    // Filter properties
    @State private var selectedFilter: String = "None"
    @State private var filterIntensity: Double = 0.5
    
    // Available Filters
    let filters = ["None", "Vivid", "Vivid Warm"]
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack {
                // Display Image
                if let image = processedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding()
                } else {
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(height: 300)
                        .overlay(Text("Select a Photo").foregroundColor(.white))
                        .padding()
                }
                
                // Select Photo Button
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Select Photo")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 20)
                }
                .padding(.top)
                
                // Adjustments Sliders
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Adjustments")
                            .font(.headline)
                            .padding([.leading, .trailing, .top], 20)
                        
                        AdjustmentSlider(title: "Exposure", value: $exposure, range: -100...100)
                        AdjustmentSlider(title: "Brilliance", value: $brilliance, range: -100...100)
                        AdjustmentSlider(title: "Highlights", value: $highlights, range: -100...100)
                        AdjustmentSlider(title: "Shadows", value: $shadows, range: -100...100)
                        AdjustmentSlider(title: "Contrast", value: $contrast, range: -100...100)
                        AdjustmentSlider(title: "Brightness", value: $brightness, range: -100...100)
                        AdjustmentSlider(title: "Black Point", value: $blackPoint, range: -100...100)
                        AdjustmentSlider(title: "Saturation", value: $saturation, range: -100...100)
                        AdjustmentSlider(title: "Vibrance", value: $vibrance, range: -100...100)
                        AdjustmentSlider(title: "Warmth", value: $warmth, range: -100...100)
                        AdjustmentSlider(title: "Tint", value: $tint, range: -100...100)
                        AdjustmentSlider(title: "Gradient", value: $gradient, range: -100...100)
                        
                    }
                }
                
                // Filters Section
                VStack(alignment: .leading) {
                    Text("Filters")
                        .font(.headline)
                        .padding([.leading, .trailing, .top], 20)
                    
                    Picker("Select Filter", selection: $selectedFilter) {
                        ForEach(filters, id: \.self) { filter in
                            Text(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.leading, .trailing], 20)
                    
                    if selectedFilter != "None" {
                        AdjustmentSlider(title: "Intensity", value: $filterIntensity, range: 0...1)
                            .padding([.leading, .trailing], 20)
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Photo Editor", displayMode: .inline)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                PhotoPicker(image: $inputImage)
            }
            .onChange(of: inputImage) { _ in applyProcessing() }
            .onChange(of: exposure) { _ in applyProcessing() }
            .onChange(of: brilliance) { _ in applyProcessing() }
            .onChange(of: highlights) { _ in applyProcessing() }
            .onChange(of: shadows) { _ in applyProcessing() }
            .onChange(of: contrast) { _ in applyProcessing() }
            .onChange(of: brightness) { _ in applyProcessing() }
            .onChange(of: blackPoint) { _ in applyProcessing() }
            .onChange(of: saturation) { _ in applyProcessing() }
            .onChange(of: vibrance) { _ in applyProcessing() }
            .onChange(of: warmth) { _ in applyProcessing() }
            .onChange(of: tint) { _ in applyProcessing() }
            .onChange(of: selectedFilter) { _ in applyProcessing() }
            .onChange(of: filterIntensity) { _ in applyProcessing() }
            .onChange(of: gradient) { _ in applyProcessing() }
        }
    }
    
    // MARK: - Functions
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        resetAdjustments()
        processedImage = inputImage
        applyProcessing()
    }
    
    func resetAdjustments() {
        exposure = 0
        brilliance = 0
        highlights = 0
        shadows = 0
        contrast = 1
        brightness = 0
        blackPoint = 0
        saturation = 1
        vibrance = 0
        warmth = 0
        tint = 0
        filterIntensity = 0.5
        selectedFilter = "None"
        gradient = 0
    }
    
    func applyProcessing() {
        guard let inputImage = inputImage else { return }
        
        let ciImage = CIImage(image: inputImage)
        var outputImage = ciImage
        
        // Apply adjustments
        applyAdjustments(to: &outputImage)
        
        // Apply filters
        applyFilters(to: &outputImage)
        
        // Convert output image back to UIImage
        if let outputImage = outputImage,
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            processedImage = uiImage
        }
    }
    func applyAdjustments(to outputImage: inout CIImage?) {
        guard var image = outputImage else { return }
        
        // Store the original image to revert if needed
        let originalImage = image
        
        // Apply Exposure Adjustment
        if exposure != 0 {
            let exposureFilter = CIFilter.exposureAdjust()
            exposureFilter.inputImage = image
            exposureFilter.ev = Float(exposure / 50)
            image = exposureFilter.outputImage ?? image
        }
        
        // Apply Brilliance Adjustment
        if brilliance != 0 {
            let brillianceFilter = CIFilter.colorControls()
            brillianceFilter.inputImage = image
            brillianceFilter.brightness = Float(brilliance / 100)
            image = brillianceFilter.outputImage ?? image
        }
        
        // Apply Highlights Adjustment
        if highlights != 0 {
            let highlightFilter = CIFilter.highlightShadowAdjust()
            highlightFilter.inputImage = image
            highlightFilter.highlightAmount = Float(highlights / 100)
            image = highlightFilter.outputImage ?? image
        }
        
        // Apply Shadows Adjustment
        if shadows != 0 {
            let shadowFilter = CIFilter.highlightShadowAdjust()
            shadowFilter.inputImage = image
            shadowFilter.shadowAmount = Float((shadows + 100) / 200)
            image = shadowFilter.outputImage ?? image
        }
        
        // Apply Contrast Adjustment
        if contrast != 1 {
            let contrastFilter = CIFilter.colorControls()
            contrastFilter.inputImage = image
            contrastFilter.contrast = Float((contrast + 100) / 50)
            image = contrastFilter.outputImage ?? image
        }
        
        // Apply Brightness Adjustment
        if brightness != 0 {
            let brightnessFilter2 = CIFilter.colorControls()
            brightnessFilter2.inputImage = image
            brightnessFilter2.brightness = Float(brightness / 100)
            image = brightnessFilter2.outputImage ?? image
        }
        
        // Apply Black Point Adjustment
        if blackPoint != 0 {
            let blackPointFilter = CIFilter.colorControls()
            blackPointFilter.inputImage = image
            blackPointFilter.brightness = Float(-blackPoint / 100)
            image = blackPointFilter.outputImage ?? image
        }
        
        // Apply Saturation Adjustment
        if saturation != 1 {
            let saturationFilter = CIFilter.colorControls()
            saturationFilter.inputImage = image
            saturationFilter.saturation = Float((saturation + 100) / 100)
            image = saturationFilter.outputImage ?? image
        }
        
        // Apply Vibrance Adjustment
        if vibrance != 0 {
            let vibranceFilter = CIFilter.vibrance()
            vibranceFilter.inputImage = image
            vibranceFilter.amount = Float(vibrance / 100)
            image = vibranceFilter.outputImage ?? image
        }
        
        // Apply Warmth Adjustment
        if warmth != 0 {
            let warmthFilter = CIFilter.temperatureAndTint()
            warmthFilter.inputImage = image
            warmthFilter.neutral = CIVector(x: CGFloat(warmth + 6500), y: CGFloat(tint + 0))
            image = warmthFilter.outputImage ?? image
        }
        
        // Apply Gradient Adjustment
        if gradient != 0 {
            let gradientFilter = CIFilter(name: "CILinearGradient")!
            let width = image.extent.width
            let height = image.extent.height
            
            gradientFilter.setValue(CIVector(x: width / 2, y: 0), forKey: "inputPoint0") // Start at top center
            gradientFilter.setValue(CIVector(x: width / 2, y: height), forKey: "inputPoint1") // End at bottom center
            
            // Color calculation based on gradient value
            let intensity = CGFloat((gradient + 100) / 200)
            gradientFilter.setValue(CIColor(red: 1, green: 0, blue: 0, alpha: intensity), forKey: "inputColor0") // Top color
            gradientFilter.setValue(CIColor(red: 0, green: 0, blue: 1, alpha: 1 - intensity), forKey: "inputColor1") // Bottom color
            
            guard let gradientImage = gradientFilter.outputImage?.cropped(to: image.extent) else { return }
            
            // Blend the gradient with the current image
            let blendFilter = CIFilter(name: "CISourceOverCompositing")!
            blendFilter.setValue(gradientImage, forKey: kCIInputImageKey)
            blendFilter.setValue(image, forKey: kCIInputBackgroundImageKey)
            
            image = blendFilter.outputImage ?? image
        } else {
            // If gradient is 0, we should keep the original image without any gradient
            outputImage = image // Maintain the last processed image without gradient effect
            return
        }
        
        // Assign the final image back to outputImage
        outputImage = image
    }
    
    
    func applyFilters(to outputImage: inout CIImage?) {
        if selectedFilter == "Vivid" {
            let vividFilter = CIFilter.colorControls()
            vividFilter.inputImage = outputImage
            vividFilter.saturation = Float(filterIntensity * 2)
            outputImage = vividFilter.outputImage
        }
        
        if selectedFilter == "Vivid Warm" {
            let vividWarmFilter = CIFilter.temperatureAndTint()
            vividWarmFilter.inputImage = outputImage
            vividWarmFilter.neutral = CIVector(x: CGFloat(7000 * filterIntensity), y: 0)
            outputImage = vividWarmFilter.outputImage
        }
    }
}

struct AdjustmentSlider: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value))")
            }
            Slider(value: $value, in: range)
        }
        .padding([.leading, .trailing], 20)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}
