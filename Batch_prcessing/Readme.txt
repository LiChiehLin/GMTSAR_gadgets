Batch processing of p2p_S1_TOPS.csh for Sentinel-1 data
There are three c-shell codes within Batch_processing/ and they should be executed in the following order:

MakeFolder.csh                |
(Arrange necessary folders).  |
                              V
Batch_align.csh                           |
(Process align_tops_esd.csh with mode 2)  |
                                          V
Batch_p2pS1TOPS.csh
(Process p2p_S1_TOPS.csh using specified configurations)

#
#Example:
#
Put all three c-shell codes in CaseDirectory/
The working directory should look like this (the image folder names should be yyyymmdd):
                  (images)
CaseDirectory/ -> 20170202/ -> S1A_IW_SLC__1SDV_20170202T095720_20170202T095747_015103_018B14_72B8.SAFE
                               S1A_OPER_AUX_POEORB_OPOD_20210315T172059_V20170201T225942_20170203T005942.EOF
                  20170208/ -> S1B_IW_SLC__1SDV_20170208T095644_20170208T095714_004207_0074A8_E197.SAFE
                               S1B_OPER_AUX_POEORB_OPOD_20210306T043325_V20170207T225942_20170209T005942.EOF
                  20170214/ -> S1A_IW_SLC__1SDV_20170214T095720_20170214T095747_015278_01909D_FEC3.SAFE
                               S1A_OPER_AUX_POEORB_OPOD_20210315T210836_V20170213T225942_20170215T005942.EOF
                      .
                      .
                      .
TopographyFolder/ -> dem.grd (It can only be named "dem.grd")
ConfigFolder/ -> config.s1a.txt (It can be named as you like)
                    
1. MakeFolder.csh
run "ls -d 2017* > RawFolder.dat" Or you can make a list of all the image folder name with other ways
Specify variable 'Raw' with RawFolder.dat
Specify variable 'topodir' with absolute path
run "csh MakeFolder.csh"

2. Batch_align.csh
Specify variable 'config' with absolute path and file name (You need to already have this file!)
Specify variable 'Raw' with RawFolder.dat
Specify variable 'subswath' of which subswath you want to work on
run "csh Batch_align.csh"

3. Batch_p2pS1TOPS.csh
Specify variable 'config' with the file name
Specify variable 'Raw' with RawFolder.dat
run "csh Batch_p2pS1TOPS.csh"


You can split the RawFolder.dat into multiple files and open multiple terminals to work at the same time
#Terminal 1
  RawFolder1.dat -> Batch_align1.csh -> Batch_p2pS1TOPS1.csh
#Terminal 2
  RawFolder2.dat -> Batch_align2.csh -> Batch_p2pS1TOPS2.csh
#Terminal 3
  RawFloder3.dat -> Batch_align3.csh -> Batch_p2pS1TOPS3.csh
.
.
.
