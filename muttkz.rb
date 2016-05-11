require 'formula'

class Muttkz < Formula
  homepage 'https://kzak.redcrew.org/doku.php?id=mutt:start'
  url 'https://github.com/karelzak/mutt-kz/archive/v1.6.0.1.tar.gz'
  sha256 '7832ba066fb6d2681450e4c32b910dfb645ae7afd99dfa6b83c33ce1c5e58cea'
  revision 1

  head do
    url 'http://dev.mutt.org/hg/mutt#default', :using => :hg

    resource 'html' do
      url 'http://dev.mutt.org/doc/manual.html', :using => :nounzip
    end
  end

  unless Tab.for_name('signing-party').used_options.include? 'with-rename-pgpring'
    conflicts_with 'signing-party',
      :because => 'mutt installs a private copy of pgpring'
  end

  conflicts_with 'tin',
    :because => 'both install mmdf.5 and mbox.5 man pages'

  conflicts_with 'mutt',
    :because => 'both install mutt and mutt man pages'

  option "with-debug", "Build with debug option enabled"
  option "with-trash-patch", "Apply trash folder patch"
  option "with-s-lang", "Build against slang instead of ncurses"
  option "with-ignore-thread-patch", "Apply ignore-thread patch"
  option "with-pgp-verbose-mime-patch", "Apply PGP verbose mime patch"

  depends_on :autoconf
  depends_on :automake

  depends_on 'openssl'
  depends_on 'tokyo-cabinet'
  depends_on 'notmuch'
  depends_on 's-lang' => :optional
  depends_on 'gpgme' => :optional

  patch do
    url "ftp://ftp.openbsd.org/pub/OpenBSD/distfiles/mutt/trashfolder-1.5.22.diff0.gz"
    sha1 "c597566c26e270b99c6f57e046512a663d2f415e"
  end if build.with? "trash-patch"

  # patching segfaults for empty keys
  # http://permalink.gmane.org/gmane.mail.mutt.devel/21951
  # patch :DATA

  # original source for this went missing, patch sourced from Arch at
  # https://aur.archlinux.org/packages/mutt-ignore-thread/
  patch do
    url "https://gist.githubusercontent.com/mistydemeo/5522742/raw/1439cc157ab673dc8061784829eea267cd736624/ignore-thread-1.5.21.patch"
    sha1 "dbcf5de46a559bca425028a18da0a63d34f722d3"
  end if build.with? "ignore-thread-patch"

  patch do
    url "https://raw.githubusercontent.com/psych0tik/mutt/73c09bc56e79605cf421a31c7e36958422055a20/debian/patches/features-old/patch-1.5.4.vk.pgp_verbose_mime"
    sha1 "a436f967aa46663cfc9b8933a6499ca165ec0a21"
  end if build.with? "pgp-verbose-mime-patch"

  def install
    args = ["--disable-dependency-tracking",
            "--disable-warnings",
            "--prefix=#{prefix}",
            "--with-ssl=#{Formula['openssl'].opt_prefix}",
            "--with-sasl",
            "--with-gss",
            "--enable-imap",
            "--enable-smtp",
            "--enable-pop",
            "--enable-hcache",
            "--with-tokyocabinet",
	    "--enable-notmuch",
            "--enable-sidebar",
            # This is just a trick to keep 'make install' from trying to chgrp
            # the mutt_dotlock file (which we can't do if we're running as an
            # unpriviledged user)
            "--with-homespool=.mbox"]
    args << "--with-slang" if build.with? 's-lang'
    args << "--enable-gpgme" if build.with? 'gpgme'

    if build.with? 'debug'
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    system "./prepare", *args
    system "make"
    system "make", "install"

    (share/'doc/mutt').install resource('html') if build.head?
  end
end

__END__
diff --git a/pgpkey.c b/pgpkey.c
index a824fd7..9d56d78 100644
--- a/pgpkey.c
+++ b/pgpkey.c
@@ -864,7 +864,7 @@ pgp_key_t pgp_getkeybyaddr (ADDRESS * a, short abilities, pgp_ring_t keyring,
 
     for (q = k->address; q; q = q->next)
     {
-      r = rfc822_parse_adrlist (NULL, q->addr);
+      r = rfc822_parse_adrlist (NULL, NONULL (q->addr));
 
       for (p = r; p; p = p->next)
       {

