%extractDecoder({'1x1'},'V1V2','leave0');
%extractDecoder({'1x1'},'V1V2','leave1');

%extractDecoder({'1x2'},'V1V2','leave0');
%extractDecoder({'1x2'},'V1V2','leave1');

%extractDecoder({'2x1'},'V1V2','leave0');
%extractDecoder('2x1'},'V1V2','leave1');

%extractDecoder({'2x2'},'V1V2','leave0');
%extractDecoder({'2x2'},'V1V2','leave1');

%% or juist write as follows,
%extractDecoder({'1x1','1x2','2x1','2x2'},'V1V2','leave0');
%extractDecoder({'1x1','1x2','2x1','2x2'},'V1V2','leave1');

%extractDecoder({'1x1','1x2','2x1','2x2'},'V1','leave0');
%extractDecoder({'1x1','1x2','2x1','2x2'},'V1','leave1');

%extractDecoder({'1x1','1x2','2x1','2x2'},'V2','leave0');
%extractDecoder({'1x1','1x2','2x1','2x2'},'V2','leave1');

%extractDecoder({'1x1','1x2','2x1','2x2'},'V3VP','leave0');
%extractDecoder({'1x1','1x2','2x1','2x2'},'V3VP','leave1');

%extractDecoder({'1x1','1x2','2x1','2x2'},'AllArea','leave0');
%extractDecoder({'1x1','1x2','2x1','2x2'},'AllArea','leave1');

%% start reconstruction for 1x1 for proposal
extractDecoder({'1x1'},'V1','leave0');
%extractDecoder({'1x1'},'V1','leave1');

%extractDecoder({'1x1'},'V2','leave0');
%extractDecoder({'1x1'},'V2','leave1');

%extractDecoder({'1x1'},'V3VP','leave0');
%extractDecoder({'1x1'},'V3VP','leave1');

%extractDecoder({'1x1'},'AllArea','leave0');
%extractDecoder({'1x1'},'AllArea','leave1');

