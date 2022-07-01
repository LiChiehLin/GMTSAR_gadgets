#!bin/csh
ls *.zip > Filelist
if (! -f RawZip) then
	mkdir RawZip
endif

foreach zip (`cat Filelist`)
	tar -xvf $zip
	mv $zip RawZip
end
