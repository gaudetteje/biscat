function h = gui_generator

h.Bullets = @genBullets;
h.Checkbox = @genCheckbox;
h.Dropdown = @genDropdown;
h.Textedit = @genTextedit;
h.Table = @genTable;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UI initialization functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = genBullets(opts,parent,pos,S)
% GENBULLETS(OPTS,PARENT,POS)  iteratively create bullet list in containing buttongroup
%
% Note:  Bullets don't get tagged directly - this should be the uibuttongroup
% parent's job.  Instead, the parent object gets populated with name in UserData.
for i=1:length(opts)
    S.(opts{i}{2}) = uicontrol('Parent',parent,...
        'Style','radiobutton',...
        'String',opts{i}{1},...
        'Value',i==1,...
        'UserData',opts{i}{2},...
        'Position',pos);
    pos(2) = pos(2)-20;             % move down by 20 pixels after each iteration
end


function S = genCheckbox(opts,parent,pos,S)
% GENCHECKBOX(OPTS,PARENT,POS)  iteratively create checkboxes in containing buttongroup
%

for i=1:length(opts)
    % adjust width of current text box
    pos = growControl(pos,opts{i}{1});
    pos(3) = pos(3) + 20;           % add additional room for check boxes
    
    % find optional callback
    if length(opts{i}) > 2
        callback = opts{i}{3};
    else
        callback = '';
    end
    
    % create control
    S.(opts{i}{2}) = uicontrol('Parent',parent,...
        'Style','checkbox',...
        'String',opts{i}{1},...
        'Tag',opts{i}{2},...
        'ButtonDownFcn',callback,...
        'Position',pos);
    
    % move position across after each iteration
    pos(1) = pos(1)+pos(3)+5;
end


function S = genDropdown(opts,parent,pos,S)
% GENDROPDOWN(OPTS,PARENT,POS)  iteratively create dropdown boxes in containing buttongroup
%

for i=1:length(opts)
    % adjust position of text to left of dropdown menu
    tpos = growControl(pos,opts{i}{1});
    tpos(1) = tpos(1) - tpos(3) - 5;    % move textbox left by its width
    
    % display text descriptor
    uicontrol('Parent',parent,...
        'Style','text',...
        'String',opts{i}{1},...
        'Horizontalalignment','right',...
        'Position',tpos);
    
    % display drop down menu
    S.(opts{i}{2}) = uicontrol('Parent',parent,...
        'Style','popupmenu',...
        'Tag',opts{i}{2},...
        'String',opts{i}{3},...
        'Value',1,...
        'Position',pos);
    
    pos(2) = pos(2)-20;             % move down by 20 pixels after each iteration
end


function S = genTextedit(opts,parent,pos,S)
% GENTEXTEDIT(OPTS,PARENT,POS)  iteratively create textboxes in containing buttongroup
%

for i=1:length(opts)
    
    % display text only (textbox group title)
    if ischar(opts{i})
        tpos = growControl(pos,opts{i});
        uicontrol('Parent',parent,...
            'Style','text',...
            'String',opts{i},...
            'HorizontalAlignment','left',...
            'Position',tpos);

    % display text and editbox
    else
        tpos = growControl(pos,opts{i}{1});
        tpos(1) = tpos(1) - tpos(3) - 5;    % move textbox left by its width
        
        uicontrol('Parent',parent,...
            'Style','text',...
            'String',opts{i}{1},...
            'HorizontalAlignment','right',...
            'Position',tpos);
        
        S.(opts{i}{2}) = uicontrol('Parent',parent,...
            'Style','edit',...
            'Tag',opts{i}{2},...
            'String',opts{i}{3},...
            'BackgroundColor','white',...
            'Position',pos);
    end

    pos(2) = pos(2)-20;             % move down by 20 pixels after each iteration
end


function S = genTable(opts,parent,pos,S)
% GENTABLE(OPTS,PARENT,POS)  create embedded 2D table in containing buttongroup
%

tpos = pos;
tpos(2) = tpos(2) + tpos(4);
tpos(4) = 20;
uicontrol('Parent',parent,...
    'Style','text',...
    'String',opts{1},...
    'Position',tpos);

% place table placeholder
H = uitable(...
    'Parent',parent,...
    'Position',pos,...
    'Tag',opts{2},...
    'ColumnName',opts{3},...
    'ColumnWidth',{(pos(3)-50)/length(opts{3})},...
    'ColumnEditable',true);%,...
    %'ColumnFormat','numeric');

% add each row of data iteratively
for i=4:length(opts)
    name = get(H,'RowName');
    if ischar(name), name = {}; end
    name{end+1} = opts{i}{1};
    set(H,'RowName',name);
    
    data = get(H,'Data');
    data(end+1,:) = opts{i}{2};
    set(H,'Data',data);
end

S.(opts{2}) = H;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  PRIVATE SUBFUNCTIONS  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newpos = growControl(pos,string)
% GROWCONTROL  takes in a position vector and adjusts width for a given text string
%
newpos = pos;
newpos(3) = max(1, 7*length(string));       % grow text width as necessary
