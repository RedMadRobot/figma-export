cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

perl -i -pe 's/\b(\d+)(?=.\d+")/$1+1/e' FigmaExport.podspec
perl -i -pe 's/\b(\d+)(?=.\d+")/$1+1/e' ./Sources/FigmaExport/FigmaExportCommand.swift

perl -i -pe 's/\b(\d+)(?=\D*$)/0/e' FigmaExport.podspec
perl -i -pe 's/\b(\d+)(?=\D*$)/0/e' ./Sources/FigmaExport/FigmaExportCommand.swift
