% MAT2NLXVT   Exports data from Matlab into a Neuralynx NVT file.
%
%   Mat2NlxVT(  Filename, AppendToFileFlag, ExportMode, ExportModeVector,
%               FieldSelectionFlags, TimeStamps, ExtractedX, ExtractedY, ExtractedAngle, Targets,
%               Points, Header);
%
%   Version 6.0.0 
%
%	Requires MATLAB R2012b (8.0) or newer
%
%   
%   Notes on export data:
%   1. Each export variable's Nth element corresponds to the Nth element in
%      all the other export variables with the exception of the header export
%      variable.
%   2. The value of N in the descriptions below is the total number of records
%      exported. The export variables do not all have to be the same length,
%      however the maximum number of records exported is limited to the
%      smallest export variable.
%   3. An item is an individual value in an array or matrix.
%   3. For more information on Neuralynx records see:
%      http://neuralynx.com/software/NeuralynxDataFileFormats.pdf
%   4. Export data will always be assigned in the order indicated in the
%      FieldSelectionFlags. If data is not imported via a FieldSelectionFlags
%      index being 0, simply omit the export variable from the command.
%      EXAMPLE: FieldSelectionFlags = [1 0 0 0 0 1 0];
%      Mat2NlxVT('test.nvt',0,1,[],FieldSelectionFlags,Timestamps,Points);
%
%
%   INPUTS:
%   FileName: String containing either the complete ('C:\CheetahData\
%             VT1.nvt') or relative ('VT1.nvt') path of the file where you
%             wish to export data. 
%   AppendToFileFlag: If this flag is a zero and the file does not exist, a new
%                     file will be created. If the file already exists, and the
%                     flag is zero, it will be overwritten with the new data
%                     without being prompted to overwrite. If this flag is a
%                     one and the file exists, the new data will be appended to
%                     the end of the existing file without checking any data in
%                     the current file. This could result in the output file
%                     not being in increasing temporal order. If the file does
%                     not exist when appending, a new file will be created.
%   ExportMode: A number indicating how export variables will be processed
%               during export. The numbers and their effect are described below:
%                  1 (Export All): Exports data from N items in each export
%                    variable.
%                  2 (Export Index Range): Exports every item whose
%                    index is within a range.
%                  3 (Export Index List): Exports a specific list of items
%                    based on item index.
%                  4 (Export Timestamp Range): Exports every item whose
%                    timestamp is within a range of timestamps.
%                  5 (Export Timestamp List): Exports a specific list of
%                    items based on their timestamp.
%   ExportModeVector: The contents of this vector varies based on the
%                     ExportMode. Each export mode is listed with a
%                     description of the ExportModeVector contents.
%                      1 (Extract All): The vector value is ignored.
%                      2 (Extract Index Range): A vector of two indices,
%                        in increasing order, indicating a range of items to
%                        export. An item index is the number of the item in
%                        each export variable in temporal order (i.e. first
%                        item is index 1, second is 2, etc.). This range is
%                        inclusive of the beginning and end indices. If the
%                        last item in the range is larger than the number of
%                        items available for export, all data until the end of
%                        the smallest of the export variables will be exported.
%                        EXAMPLE: [10 50] exports the 10th item in each export
%                        variable through the 50th item (total of 41 items).
%                      3 (Export Index List): A vector of indices
%                        indicating individual items to export. An item index
%                        is the number of the item in each export variable in
%                        temporal order (i.e. first item is index 1, second is
%                        2, etc.). Data will be exported in the order
%                        specified by this vector. If an index in the
%                        vector is less than 1 or greater than the number of
%                        items in the smallest of the export variables, the
%                        index will be skipped.
%                        EXAMPLE: [7 10 1] exports item 7 then 10 then 1, from
%                        each export variable, and it is not sorted temporally
%                      4 (Export Timestamp Range): A vector of two timestamps,
%                        in increasing order, indicating a range of time to use
%                        when exporting items. This mode requires that you
%                        have timestamps as one of the export variables and
%                        that the timestamps are sorted in ascending order.
%                        If either of the timestamps in this vector are not 
%                        contained within the timestamps export variable,
%                        the range will be set to the closest valid timestamp
%                        (e.g. first or last). The range is inclusive of the
%                        beginning and end timestamps.
%                        EXAMPLE: [12500 25012] exports all items that
%                        correspond to the items in the timestamps export
%                        variable between the timestamps 12500 and 25012,
%                        inclusive of data at those times (i.e. if 12500
%                        corresponds to item 10 in the timestamps export
%                        variable, item 10 will be exported for all other
%                        export variables).
%                      5 (Extract Timestamp List): A vector of timestamps
%                        indicating individual items to extract sorted in
%                        ascending order. This mode requires that you have
%                        timestamps as one of the export variables and that the
%                        timestamps are sorted in ascending order. If a
%                        specified timestamp does not exactly match a timestamp
%                        in the timestamps export variable,the timestamp will
%                        be ignored.
%                        EXAMPLE: [10125 45032 75000] exports items that
%                        that correspond to the items in the timestamps export
%                        variable at timestamp 10125, 45032 and 75000. (i.e.
%                        if 10125 corresponds to item 10 in the timestamps
%                        export variable, item 10 will be exported for all
%                        other export variables)
%   FieldSelectionFlags: Vector with each item being either a zero (excludes
%                        data) or a one (includes data) that determines which
%                        export variables will be necessary. The order of
%                        the items in the vector correspond to the following:
%                           FieldSelectionFlags(1): Timestamps
%                           FieldSelectionFlags(2): Extracted X
%                           FieldSelectionFlags(3): Extracted Y
%                           FieldSelectionFlags(4): Extracted Angle
%                           FieldSelectionFlags(5): Targets
%                           FieldSelectionFlags(6): Points
%                           FieldSelectionFlags(7): Header
%                        EXAMPLE: [1 0 0 0 0 1 0] exports timestamp and point
%                        vectors and excludes all other data.
%   Timestamps: A 1xN integer vector of timestamps.
%   Extracted X: A 1xN integer vector of the calculated X coordinate for each record.
%   Extracted Y: A 1xN integer vector of the calculated Y coordinate for each record.
%   Extracted Angle: A 1xN integer vector of the calculated head direction angle for
%                    each record. This value is in degrees.
%   Targets: A 50xN integer matrix of the targets found for each frame. These values
%            are encoded using the VT bitfield encoding.
%   Points: A 480xN integer matrix of the threshold crossings found for each frame.
%           These values are encoded using the VT bitfield encoding.
%   Header: A Mx1 string vector of all the text from the Neuralynx file header, where
%           M is the number of lines of text in the header.
%
%   EXAMPLE: Mat2NlxVT('test.nvt', 0, 1, [], [1 1 1 1 1 1],
%                      Timestamps, X, Y, Angles, Targets, Points, Header);
%   Uses export mode 1 to export all of the data (assuming N is identical for
%   all export variables) from all of the export variables to the file
%   test.nvt, overwriting any data that may be in that file.
%

