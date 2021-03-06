#!/bin/tcsh
#set echo
#set verbose

#Enter necessary filename variables here
#echo "This scripts runs Hron Turek FSI3 problem in parallel with 4 cores for 0.05 s using 0.0005 s timesteps."
#echo "$# arguments supplied to me."
#echo "$1"
#echo "$2"
#echo "$argv[1]"
set OutFile = ${1}
set TmpOut = ${OutFile}_tmp.txt
set InputDir = HronTurekFSI3_4
set Outputs = ./fluid/probe_proc_2_nde_4.dat
set OutputsCheck = ./fluid/ref_4.dat
set TestName = HronTurekFSI3_4:Works

#Remove old test InputDir if present
if( -d  ${InputDir}) then
  echo "removing ${InputDir} directory"
  rm -r ${InputDir}
endif

#Make InputDir directory to run test in
mkdir ${InputDir}
cd ${InputDir}

#Copy input data into InputDir
echo "$2/share/Testing/test_data/${InputDir}/"
cp -r $2/share/Testing/test_data/${InputDir}/* .

#Run executable to generate output data
#(HINT: $3 IS THE PATH TO THE BIN DIRECTORY GIVEN WHEN CALLING RUNTEST)
./Allclean
./AllrunParDrvSetup
cd ./fluid
mpirun -np 4 $3/elmerfoamfsiPar -v 2 test.config
cd ..

#Make sure the necesary output was generated
foreach file (${Outputs})
  if( ! -e ${file} ) then
    echo "No ${file} results file from run!"
    exit 1
  endif
end

#variable for test passing
@ result = 1

#diff the new output file with the saved one to check
#(This uses our own speical diff (diffdatafiles) that
#can compare numbers with a tolerance. See documentation
#for more information on how to use it.)
@ i = 1
foreach file (${Outputs})
  #$4/diffdatafiles ${file} $OutputsCheck[$i] -t 1.0e-10 -n
  diff ${file} $OutputsCheck[$i]
  if($? != 0) then
    echo "${file} differs from $OutputsCheck[$i]"
    @ result = 0
  endif
  @ i += 1
end

#print test results to OutFile
printf "${TestName}=" >> ${TmpOut}
printf "$result\n" >> ${TmpOut}
cat ${TmpOut} >> ../${OutFile}
cd ..
rm -r ${InputDir}

exit 0

