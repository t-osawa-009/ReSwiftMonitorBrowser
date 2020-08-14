.PHONY: sort_file
sort_file:
	Scripts/sort-Xcode-project-file.pl ReSwiftMonitorBrowser.xcodeproj/project.pbxproj

.PHONY: open_xcode
open_xcode:
	open ReSwiftMonitorBrowser.xcodeproj