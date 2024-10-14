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
    
    // Core Image context and filters
    let context = CIContext()
    let filter = CIFilter.colorControls()
    
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
                        
                        // Example Slider: Exposure
                        AdjustmentSlider(title: "Exposure", value: $exposure, range: -5...5)
                        // Add more sliders for other adjustments
                        AdjustmentSlider(title: "Brilliance", value: $brilliance, range: -100...100)
                        AdjustmentSlider(title: "Highlights", value: $highlights, range: -100...100)
                        AdjustmentSlider(title: "Shadows", value: $shadows, range: -100...100)
                        AdjustmentSlider(title: "Contrast", value: $contrast, range: 0...4)
                        AdjustmentSlider(title: "Brightness", value: $brightness, range: -1...1)
                        AdjustmentSlider(title: "Black Point", value: $blackPoint, range: 0...1)
                        AdjustmentSlider(title: "Saturation", value: $saturation, range: 0...2)
                        AdjustmentSlider(title: "Vibrance", value: $vibrance, range: -100...100)
                        AdjustmentSlider(title: "Warmth", value: $warmth, range: -100...100)
                        AdjustmentSlider(title: "Tint", value: $tint, range: -100...100)
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
        }
    }
    
    // MARK: - Functions
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        processedImage = inputImage
        applyProcessing()
    }
    
    func applyProcessing() {
        guard let inputImage = inputImage else { return }
        
        let ciImage = CIImage(image: inputImage)
        
        // Start with the original image
        var outputImage = ciImage
        
        // Apply Exposure
        if exposure != 0 {
            let exposureFilter = CIFilter.exposureAdjust()
            exposureFilter.inputImage = outputImage
            exposureFilter.ev = Float(exposure)
            outputImage = exposureFilter.outputImage
        }
        
        // Apply Brilliance (using brightness)
        if brilliance != 0 {
            let brightnessFilter = CIFilter.colorControls()
            brightnessFilter.inputImage = outputImage
            brightnessFilter.brightness = Float(brilliance / 100)
            outputImage = brightnessFilter.outputImage
        }
        
        // Apply Contrast
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = outputImage
        contrastFilter.contrast = Float(contrast)
        outputImage = contrastFilter.outputImage
        
        // Apply Brightness
        let brightnessFilter2 = CIFilter.colorControls()
        brightnessFilter2.inputImage = outputImage
        brightnessFilter2.brightness = Float(brightness)
        outputImage = brightnessFilter2.outputImage
        
        // Apply Saturation
        let saturationFilter = CIFilter.colorControls()
        saturationFilter.inputImage = outputImage
        saturationFilter.saturation = Float(saturation)
        outputImage = saturationFilter.outputImage
        
        // Apply Warmth and Tint
        if warmth != 0 || tint != 0 {
            let tempAndTintFilter = CIFilter.temperatureAndTint()
            tempAndTintFilter.inputImage = outputImage
            
            // Adjust warmth and tint by setting neutral and target neutral values
            let neutralVector = CIVector(x: CGFloat(Float(warmth)), y: 0)
            let targetNeutralVector = CIVector(x: CGFloat(Float(tint)), y: 0)
            
            tempAndTintFilter.setValue(neutralVector, forKey: "inputNeutral")
            tempAndTintFilter.setValue(targetNeutralVector, forKey: "inputTargetNeutral")
            
            outputImage = tempAndTintFilter.outputImage
        }
        
        // Apply Filters
        if selectedFilter == "Vivid" {
            let vividFilter = CIFilter.photoEffectChrome()
            vividFilter.inputImage = outputImage
            outputImage = vividFilter.outputImage
        } else if selectedFilter == "Vivid Warm" {
            let vividWarmFilter = CIFilter.photoEffectProcess()
            vividWarmFilter.inputImage = outputImage
            outputImage = vividWarmFilter.outputImage
        }
        
        // Convert output image back to UIImage
        if let outputImage = outputImage,
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            processedImage = uiImage
        }
    }
    
    
    // MARK: - Photo Picker
    
    struct PhotoPicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            let parent: PhotoPicker
            
            init(parent: PhotoPicker) {
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
        
        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
        
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration()
            config.filter = .images // Only images
            config.selectionLimit = 1 // Single selection
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    }
    
    // MARK: - Adjustment Slider View
    
    struct AdjustmentSlider: View {
        var title: String
        @Binding var value: Double
        var range: ClosedRange<Double>
        
        var body: some View {
            VStack {
                HStack {
                    Text(title)
                    Spacer()
                    Text(String(format: "%.2f", value))
                }
                Slider(value: $value, in: range)
            }
            .padding([.leading, .trailing], 20)
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
