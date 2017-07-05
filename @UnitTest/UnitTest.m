classdef UnitTest < matlab.unittest.TestCase
% UnitTest is a modular test case class for MATLAB applications. 
% When executed via runtests(), this class will automatically run a series
% of unit tests against the specified executable, and create Markdown 
% reports summarizing the results. The MATLAB profiler is turned on during 
% unit test execution to quantify the code coverage.
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2017 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

    % Define UnitTest class properties
    properties
               
        % executable stores the name of the application
        executable = @TomoExport
        
        % configFile stores the name of the config file relative path
        configFile = 'config.txt'
        
        % inputData stores a cell array of patient archives that will be
        % tested during these unit tests
        inputData = {
            'DB v2'                 '../test_data/DBv2/Anon_0007.xml'
            'DB v6'                 '../test_data/DBv6/Anon_0002_patient.xml'
            'CoordinatedPlan'       '../test_data/CoordinatedPlan/Anon_0001_patient.xml'
            'EnhancedReportsFinal'  '../test_data/EnhancedReportsFinal/Anon_0003_patient.xml'
            'TPPlus1'               '../test_data/TPPlus1/Anon_0004_patient.xml'
            'TPPlus1 (Direct)'      '../test_data/TPPlus1 Direct/Anon_0005_patient.xml'
            'TPPlus1 (FFP)'         '../test_data/TPPlus1 FFP/Anon_0006_patient.xml'
        }
    
        % referenceData stores a cell array of MATLAB variables containing
        % the expected contents of each archive above
        referenceData = {
            'DB v2'                 '../test_data/DBv2/reference.mat'
            'DB v6'                 '../test_data/DBv6/reference.mat'
            'CoordinatedPlan'       '../test_data/CoordinatedPlan/reference.mat'
            'EnhancedReportsFinal'  '../test_data/EnhancedReportsFinal/reference.mat'
            'TPPlus1'               '../test_data/TPPlus1/reference.mat'
            'TPPlus1 (Direct)'      '../test_data/TPPlus1 Direct/reference.mat'
            'TPPlus1 (FFP)'         '../test_data/TPPlus1 FFP/reference.mat'
        }
    
        % exportPath stores a temporary path to export the DICOM files to
        exportPath = '../test_reports/DICOM/';
        
        % dicomData stores a cell array of paths to reference DICOM files
        % to compare to the DICOM files exported from this tool
        dicomData = {
            'Anon_0007'     '../test_data/Reference DICOM/Anon_0007'
            'Anon_0002'     '../test_data/Reference DICOM/Anon_0002'
            'Anon_0001'     '../test_data/Reference DICOM/Anon_0001'
            'Anon_0003'     '../test_data/Reference DICOM/Anon_0003'
            'Anon_0004'     '../test_data/Reference DICOM/Anon_0004'
            'Anon_0005'     '../test_data/Reference DICOM/Anon_0005'
            'Anon_0006'     '../test_data/Reference DICOM/Anon_0006'
        }
        
        % figure stores the application UI handle. It is used during
        % teardown to close the figure
        figure = [];
        
        % config stores a structure of config file contents
        config = struct
        
        % configOriginal stores a duplicate copy of the original config
        % file contents, to return the config file to its original state
        configOriginal = struct
        
        % reportFile stores the name of the markdown report file
        reportFile = '../test_reports/unit_test_report.md'
        
        % traceMatrix stores the name of the markdown traceability matrix
        traceMatrix = '../test_reports/unit_trace_matrix.md'
        
        % stats store the profiler results
        stats = [];
    end
    
    % Define test level setup functions
    methods(TestMethodSetup)
        
    end
 
    % Define test level teardown functions
    methods(TestMethodTeardown)
        CloseFigure(testCase)
        RestoreOriginalConfig(testCase)
    end
 
    % Define class level setup functions
    methods (TestClassSetup)
        ReadOriginalConfig(testCase)
        StartProfiler(testCase)
    end
    
    % Define class level teardown functions
    methods (TestClassTeardown)
        WriteMarkdownReport(testCase)
        WriteTraceabilityMatrix(testCase)
        StopProfiler(testCase)
    end
    
    % Define supporting methods
    methods (Static, Access = public)
        info = CPUInfo()
        info = MemInfo()
        sl = SLOC(file)
        WriteConfigFile(filename, config)
        config = ReadConfigFile(filename)
        [image, dose] = LoadDICOMFiles(path)
        varargout = StoreResults(varargin)
    end
    
    % Define unit tests
    methods(Test, TestTags = {'Unit'})
        Test01(testCase)
        Test02(testCase)
        Test03(testCase)
        Test04(testCase)
        Test05(testCase)
        Test06(testCase)
        Test07(testCase)
        Test08(testCase)
        Test09(testCase)
        Test10(testCase)
        Test11(testCase)
    end
end