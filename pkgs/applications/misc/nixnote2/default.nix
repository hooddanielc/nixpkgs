{ stdenv, mkDerivation, fetchFromGitHub, boost, qtbase, qtwebkit, poppler_qt5, qmake, hunspell, html-tidy}:

mkDerivation rec {
  name = "nixnote2-${version}";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "baumgarr";
    repo = "nixnote2";
    rev = "v${version}";
    sha256 = "0cfq95mxvcgby66r61gclm1a2c6zck5aln04xmg2q8kg6p9d31fr";
  };

  buildInputs = [ boost qtbase qtwebkit poppler_qt5 hunspell ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ qmake ];

  postPatch = ''
    # Fix location of poppler-qt5.h
    for f in threads/indexrunner.cpp html/noteformatter.cpp utilities/noteindexer.cpp gui/plugins/popplerviewer.h gui/plugins/pluginfactory.h gui/plugins/popplerviewer.cpp ; do
      substituteInPlace $f \
        --replace '#include <poppler-qt5.h>' '#include <poppler/qt5/poppler-qt5.h>'
    done

    substituteInPlace help/about.html --replace '__VERSION__' '${version}'

    substituteInPlace nixnote.cpp --replace 'tidyProcess.start("tidy' 'tidyProcess.start("${html-tidy}/bin/tidy'
  '';
  
  postInstal = ''
    cp images/windowIcon.png $out/share/pixmaps/nixnote2.png
  '';

  meta = with stdenv.lib; {
    description = "An unofficial client of Evernote";
    homepage = http://www.nixnote.org/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ htr ];
    platforms = platforms.linux;
  };
}
