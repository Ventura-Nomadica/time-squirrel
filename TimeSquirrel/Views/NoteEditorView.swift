import SwiftUI
import WebKit

struct NoteEditorView: View {
    @Binding var text: String
    @State private var showPreview = false

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 4) {
                Text("Notes")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Format buttons (only in edit mode)
                if !showPreview {
                    FormatButton(icon: "bold", tooltip: "Bold") { wrapSelection(prefix: "**", suffix: "**") }
                    FormatButton(icon: "italic", tooltip: "Italic") { wrapSelection(prefix: "*", suffix: "*") }
                    FormatButton(icon: "text.heading", tooltip: "Heading") { insertAtLineStart("## ") }
                    FormatButton(icon: "list.bullet", tooltip: "Bullet") { insertAtLineStart("- ") }
                    FormatButton(icon: "curlybraces", tooltip: "Code") { wrapSelection(prefix: "`", suffix: "`") }
                }

                Divider().frame(height: 16)

                Button(action: { showPreview.toggle() }) {
                    Image(systemName: showPreview ? "eye.fill" : "eye")
                        .font(.caption)
                        .foregroundColor(showPreview ? Color.tsAccent : .secondary)
                }
                .buttonStyle(.plain)
                .help("Toggle preview")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.04))

            Divider()

            // Content
            if showPreview {
                MarkdownPreviewView(markdown: text)
            } else {
                PlainTextEditor(text: $text)
            }
        }
    }

    private func wrapSelection(prefix: String, suffix: String) {
        // Append at end as a best-effort without selection context
        text += "\(prefix)text\(suffix)"
    }

    private func insertAtLineStart(_ marker: String) {
        text += "\n\(marker)"
    }
}

struct FormatButton: View {
    let icon: String
    let tooltip: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.caption)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .foregroundColor(.secondary)
        .help(tooltip)
    }
}

// MARK: - Plain text editor using NSTextView for proper selection access

struct PlainTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else { return scrollView }
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        init(text: Binding<String>) { self.text = text }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            text.wrappedValue = tv.string
        }
    }
}

// MARK: - Markdown preview using WKWebView

struct MarkdownPreviewView: NSViewRepresentable {
    let markdown: String

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = false
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let html = wrapHTML(convertToHTML(markdown))
        webView.loadHTMLString(html, baseURL: nil)
    }

    private func convertToHTML(_ md: String) -> String {
        let lines = md.components(separatedBy: "\n")
        var html = ""
        var inCodeBlock = false
        var inList = false

        for line in lines {
            if line.hasPrefix("```") {
                if inList { html += "</ul>\n"; inList = false }
                inCodeBlock.toggle()
                html += inCodeBlock ? "<pre><code>" : "</code></pre>\n"
                continue
            }
            if inCodeBlock {
                html += escapeHTML(line) + "\n"
                continue
            }
            if line.hasPrefix("### ") {
                if inList { html += "</ul>\n"; inList = false }
                html += "<h3>\(inlineMarkdown(String(line.dropFirst(4))))</h3>\n"
            } else if line.hasPrefix("## ") {
                if inList { html += "</ul>\n"; inList = false }
                html += "<h2>\(inlineMarkdown(String(line.dropFirst(3))))</h2>\n"
            } else if line.hasPrefix("# ") {
                if inList { html += "</ul>\n"; inList = false }
                html += "<h1>\(inlineMarkdown(String(line.dropFirst(2))))</h1>\n"
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                if !inList { html += "<ul>\n"; inList = true }
                html += "<li>\(inlineMarkdown(String(line.dropFirst(2))))</li>\n"
            } else if line.isEmpty {
                if inList { html += "</ul>\n"; inList = false }
                html += "<br>\n"
            } else {
                if inList { html += "</ul>\n"; inList = false }
                html += "<p>\(inlineMarkdown(line))</p>\n"
            }
        }
        if inList { html += "</ul>\n" }
        return html
    }

    private func inlineMarkdown(_ text: String) -> String {
        var result = escapeHTML(text)
        // Bold
        result = applyPattern(result, pattern: #"\*\*(.+?)\*\*"#, replacement: "<strong>$1</strong>")
        result = applyPattern(result, pattern: #"__(.+?)__"#, replacement: "<strong>$1</strong>")
        // Italic
        result = applyPattern(result, pattern: #"\*(.+?)\*"#, replacement: "<em>$1</em>")
        result = applyPattern(result, pattern: #"_(.+?)_"#, replacement: "<em>$1</em>")
        // Inline code
        result = applyPattern(result, pattern: #"`(.+?)`"#, replacement: "<code>$1</code>")
        return result
    }

    private func applyPattern(_ input: String, pattern: String, replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return input }
        let range = NSRange(input.startIndex..., in: input)
        return regex.stringByReplacingMatches(in: input, range: range, withTemplate: replacement)
    }

    private func escapeHTML(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            decisionHandler(.cancel)
        }
    }

    private func wrapHTML(_ body: String) -> String {
        """
        <!DOCTYPE html><html><head>
        <meta charset="UTF-8">
        <style>
          :root { color-scheme: light dark; }
          body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            font-size: 13px;
            line-height: 1.6;
            padding: 12px 16px;
            margin: 0;
          }
          pre { background: rgba(128,128,128,0.1); padding: 10px; border-radius: 6px; overflow-x: auto; }
          code { font-family: "SF Mono", monospace; font-size: 12px; background: rgba(128,128,128,0.1); padding: 1px 4px; border-radius: 3px; }
          pre code { background: none; padding: 0; }
          h1, h2, h3 { margin-top: 0.8em; margin-bottom: 0.3em; }
          p { margin: 0.4em 0; }
          ul { padding-left: 1.4em; margin: 0.4em 0; }
        </style></head><body>
        \(body)
        </body></html>
        """
    }
}
