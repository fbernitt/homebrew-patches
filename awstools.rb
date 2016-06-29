require 'formula'

class Awstools < Formula
  desc "A few helpful AWS tools"
  homepage "https://github.com/sam701/awstools"
  url "https://github.com/sam701/awstools/releases/download/0.7.0/awstools_darwin_amd64"
  sha256 "93af7bc32900b9b8fdb04381389e8e2ae4565f1067e5be6a02e7ecbfca255940"
  head "https://github.com/sam701/awstools.git"
  version "0.7.0"

  bottle :unneeded

  def install
    bin.install "awstools_darwin_amd64"
    mv bin/"awstools_darwin_amd64", bin/"awstools"
  end

end
