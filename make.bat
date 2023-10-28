cd .\tests\
for %%x in (*.hfm) do del "%%x" 
for %%x in (*.bin) do ..\tools\huffmunch.exe -B "%%x" "%%~nx.bin.hfm"

cd ..
cmd /c "BeebAsm.exe -v -i huffmunch_test.s.asm -do huffmunch_test.ssd -opt 3"