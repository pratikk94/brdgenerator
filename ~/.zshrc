# Add Ruby gems to PATH
export PATH="$PATH:$(gem environment gemdir)/bin" 

# The `pod` Command Is Not Found
# I see the issue - even though you might have installed CocoaPods, the `pod` command isn't in your system PATH.

# Fix: Add the Gem Path to Your Shell
# Find where gems are installed
gem environment

# Look for "EXECUTABLE DIRECTORY" in the output
# It should be something like: /Users/username/.gem/ruby/2.6.0/bin

# Now add that path to your shell configuration:
~/.gem/ruby/2.6.0/bin/pod setup
~/.gem/ruby/2.6.0/bin/pod install

# If You're Using Homebrew Ruby
# If you installed Ruby via Homebrew, you might need:
# brew link --overwrite ruby

# Try one of these approaches and then run:
# pod --version

# If it shows a version number, your CocoaPods installation is now correctly in your PATH! 