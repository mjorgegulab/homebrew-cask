cask "libreoffice-still" do
  arch arm: "aarch64", intel: "x86-64"
  folder = on_arch_conditional arm: "aarch64", intel: "x86_64"

  version "24.2.5"
  sha256 arm:   "4e655f5e7eab065bf792f7826edaea8de29d822e853826b45047f42a2a4fed8d",
         intel: "838d775690901b866f805d2bf00f2538eee9416723a326f70b31c8f1c8447646"

  url "https://download.documentfoundation.org/libreoffice/stable/#{version}/mac/#{folder}/LibreOffice_#{version}_MacOS_#{arch}.dmg",
      verified: "download.documentfoundation.org/libreoffice/stable/"
  name "LibreOffice Still"
  desc "Free cross-platform office suite, stable version recommended for enterprises"
  homepage "https://www.libreoffice.org/"

  # LibreOffice "still" releases are the stable versions with a lower
  # major/minor.
  livecheck do
    url "https://download.documentfoundation.org/libreoffice/stable/"
    regex(%r{href=["']v?(\d+(?:\.\d+)+)/?["' >]}i)
    strategy :page_match do |page, regex|
      versions = page.scan(regex).map(&:first)
      uniq_major_minor = versions.map { |version| Version.new(version).major_minor }.uniq.sort.reverse
      next if uniq_major_minor.length < 2

      versions.select { |version| Version.new(version).major_minor == uniq_major_minor[1] }
    end
  end

  conflicts_with cask: "libreoffice"
  depends_on macos: ">= :catalina"

  app "LibreOffice.app"
  binary "#{appdir}/LibreOffice.app/Contents/MacOS/gengal"
  binary "#{appdir}/LibreOffice.app/Contents/MacOS/regview"
  binary "#{appdir}/LibreOffice.app/Contents/MacOS/senddoc"
  binary "#{appdir}/LibreOffice.app/Contents/MacOS/uno"
  binary "#{appdir}/LibreOffice.app/Contents/MacOS/unoinfo"
  binary "#{appdir}/LibreOffice.app/Contents/MacOS/unopkg"
  binary "#{appdir}/LibreOffice.app/Contents/MacOS/uri-encode"
  binary "#{appdir}/LibreOffice.app/Contents/MacOS/xpdfimport"
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/soffice.wrapper.sh"
  binary shimscript, target: "soffice"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/sh
      '#{appdir}/LibreOffice.app/Contents/MacOS/soffice' "$@"
    EOS
  end

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/org.libreoffice.script.sfl*",
    "~/Library/Application Support/LibreOffice",
    "~/Library/Preferences/org.libreoffice.script.plist",
    "~/Library/Saved Application State/org.libreoffice.script.savedState",
  ]
end
