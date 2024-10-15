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
                        AdjustmentSlider(title: "Exposure", value: $exposure, range: -100...100)
                        // Add more sliders for other adjustments
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
        // Reset all adjustment values to their defaults
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
        processedImage = inputImage
        applyProcessing()
    }
    
    func applyProcessing() {
        guard let inputImage = inputImage else { return }
        
        let ciImage = CIImage(image: inputImage)
        var outputImage = ciImage
        
        // Apply Exposure (only if not default)
        if exposure != 0 {
            let exposureFilter = CIFilter.exposureAdjust()
            exposureFilter.inputImage = outputImage
            exposureFilter.ev = Float(exposure / 50) // Scaling -100...100 to -2...2
            outputImage = exposureFilter.outputImage
        }
        
        // Apply Brilliance (only if not default)
        if brilliance != 0 {
            let brightnessFilter = CIFilter.colorControls()
            brightnessFilter.inputImage = outputImage
            brightnessFilter.brightness = Float(brilliance / 100) // -100...100 to -1...1
            outputImage = brightnessFilter.outputImage
        }
        
        // Apply Highlights (only if not default)
        if highlights != 0 {
            let highlightFilter = CIFilter.highlightShadowAdjust()
            highlightFilter.inputImage = outputImage
            highlightFilter.highlightAmount = Float(highlights / 100) // -100...100 to 0...1
            outputImage = highlightFilter.outputImage
        }
        
        // Apply Shadows (only if not default)
        if shadows != 0 {
            let shadowFilter = CIFilter.highlightShadowAdjust()
            shadowFilter.inputImage = outputImage
            shadowFilter.shadowAmount = Float((shadows + 100) / 200) // Scaling -100...100 to 0...1
            outputImage = shadowFilter.outputImage
        }
        
        // Apply Contrast (only if not default)
        if contrast != 1 {
            let contrastFilter = CIFilter.colorControls()
            contrastFilter.inputImage = outputImage
            contrastFilter.contrast = Float((contrast + 100) / 50) // -100...100 to 0...4
            outputImage = contrastFilter.outputImage
        }
        
        // Apply Brightness (only if not default)
        if brightness != 0 {
            let brightnessFilter2 = CIFilter.colorControls()
            brightnessFilter2.inputImage = outputImage
            brightnessFilter2.brightness = Float(brightness / 100) // -100...100 to -1...1
            outputImage = brightnessFilter2.outputImage
        }
        
        // Apply Black Point (only if not default)
        if blackPoint != 0 {
            let blackPointFilter = CIFilter.colorControls()
            blackPointFilter.inputImage = outputImage
            blackPointFilter.brightness = Float(-blackPoint / 100) // Inverted black point scaling
            outputImage = blackPointFilter.outputImage
        }
        
        // Apply Saturation (only if not default)
        if saturation != 1 {
            let saturationFilter = CIFilter.colorControls()
            saturationFilter.inputImage = outputImage
            saturationFilter.saturation = Float((saturation + 100) / 100)
            outputImage = saturationFilter.outputImage
        }
        
        // Apply Vibrance (only if not default)
        if vibrance != 0 {
            let vibranceFilter = CIFilter.vibrance()
            vibranceFilter.inputImage = outputImage
            vibranceFilter.amount = Float(vibrance / 100) // Vibrance -100...100 scaled to -1...1
            outputImage = vibranceFilter.outputImage
        }
        
        // Apply Warmth and Tint (only if not default)
        // Corrected Warmth and Tint with Clamping
        if warmth != 0 || tint != 0 {
            let temperatureAndTintFilter = CIFilter.temperatureAndTint()
            temperatureAndTintFilter.inputImage = outputImage
            
            // Clamp warmth and tint to avoid extreme values causing invalid images
            let clampedWarmth = min(max(warmth, -100), 100)
            let clampedTint = min(max(tint, -5), 5)      // Limit tint to -5...5 range
            
            // Adjust neutral and targetNeutral based on clamped values
            let neutral = CIVector(x: 6500 + CGFloat(clampedWarmth * 50), y: 0)  // Adjusted Warmth scaling
            let targetNeutral = CIVector(x: 6500, y: CGFloat(clampedTint * 100)) // Adjusted Tint scaling
            
            temperatureAndTintFilter.neutral = neutral
            temperatureAndTintFilter.targetNeutral = targetNeutral
            
            if let filteredImage = temperatureAndTintFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        
        // Apply Filters (only if not "None")
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
