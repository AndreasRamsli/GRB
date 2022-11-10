
* The main file is `harvest_calibration_data_from_TRIGGERS_V7.m` in the first line you have important variable you can change : `WANTED_DATETIME` and `TIME_WINDOW_IN_MINUTES`

* also a path vatiable `TargetDir` that you have to change according to where the ASIM ASDC data is located in your computer

* it will produce a .mat file named for example `2020_3_4_12_34_13.mat` that is year month day hour minute second of the WANTED_TIME

* the file contains a list of many elements and 9 columns, each line are single counts, with the following order: 

* `YEAR` `MONTH` `DAY` `HOUR` `MINUTE` `SECOND`(with 4 digits after coma precision) `ENERGY_CHANNEL` `DAU_NB` `DET_NB`

* `ENERGY_CHANNEL` is between 0 and 4095

* `DAU_NB` is between 0 and 3 and `DET_NB` is between 0 and 2 (as there are 12 BGO detectors in total)

* the code is a bit slow (few minutes to run) as it will try to read all the triggers in all the files of the day of year corresponding to the `WANTED_TIME`

