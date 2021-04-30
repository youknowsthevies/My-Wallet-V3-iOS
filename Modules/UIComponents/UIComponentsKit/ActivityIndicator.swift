// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A replacement for ProgressView that supports iOS 13
public struct ActivityIndicatorView: View {
    
    private struct ActivityIndicator: UIViewRepresentable {
        
        @Binding var isAnimating: Bool
        
        func makeUIView(context: Context) -> UIActivityIndicatorView {
            let v = UIActivityIndicatorView()
            
            return v
        }
        
        func updateUIView(_ activityIndicator: UIActivityIndicatorView, context: Context) {
            if isAnimating {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    public init() {
        // required for exposing the view to the external world
    }
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            ProgressView()
        } else {
            ActivityIndicator(isAnimating: .constant(true))
        }
    }
}

#if DEBUG
struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView()
    }
}
#endif
