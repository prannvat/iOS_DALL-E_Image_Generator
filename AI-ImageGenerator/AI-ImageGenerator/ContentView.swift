//
//  ContentView.swift
//  AI-ImageGenerator
//
//  Created by Prannvat Singh on 10/10/2023.
//

import SwiftUI
import OpenAIKit

final class ViewModel: ObservableObject {
    
    private var openai: OpenAI?
    func setup() {
            openai = OpenAI(Configuration(
            organizationId: "Personal",
            apiKey: "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"))
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        do {
            let params = ImageParameters(
                prompt: prompt,
                resolution: .medium,
                responseFormat: .base64Json
            )
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        }
        catch {
            print(String(describing: error))
            return nil
        }
        
    }
    
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
                else {
                    Spacer()
                    Text("Type prompt to generate image!")
                 
                }
                Spacer()
                TextField("Type prompt here...", text: $text)
                    .padding()
                Button("Generate!") {
                        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                            Task {
                                let result = await viewModel.generateImage(prompt: text)
                                if result == nil {
                                    print("Failed to get image")
                                }
                                self.image = result
                            }
                        }
                        
                }
                }
            }
            .navigationTitle("DALL-E Image Generator")
            .navigationBarHidden(false)
            .onAppear{
                viewModel.setup()
            }
            .padding()
        }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
