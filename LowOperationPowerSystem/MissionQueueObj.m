% Mission-handling class linked to a listbox in GUI
% Each entry in the listbox corresponds to an element in a user-defined
% cell array.
% QueueObj element (not a cell) will be returned upon reading
% Author: Xinbai Li

classdef MissionQueueObj < handle
    properties
        Listboxhandle;
        Listboxcontent={''}; % cell, all the content in the listbox
        nListboxentry=0; % number of entries in the listbox
        
        QueueObj; % 1xn cell, Element example: a coordinate vector [0,5,20]
        
    end
    
    methods
        function obj=MissionQueueObj(handles)
            obj.Listboxhandle=handles;
            obj.Listboxhandle.Value=1;
        end
        
        function AddtoQueue(obj,NextQueueObj,ShownContent)
                if iscell(NextQueueObj)
                    if length(NextQueueObj)==1
                        obj.QueueObj(end+1)=NextQueueObj;
                    else
                        obj.QueueObj{end+1}={NextQueueObj};
                    end
                else
                    obj.QueueObj{end+1}=NextQueueObj;
                end
            if obj.nListboxentry
                    % append
                AppendText(obj,ShownContent);
            else
                % first entry
                obj.nListboxentry=1;
                obj.Listboxcontent={ShownContent};
                obj.Listboxhandle.String=obj.Listboxcontent;
            end
            obj.Listboxhandle.Value=obj.nListboxentry;
        end

        function EditQueue(obj,nIndex,NextQueueObj,ShownContent)
            % if nIndex=[], use listbox.Value (seleted one)
            if isempty(nIndex)
                nIndex=obj.Listboxhandle.Value;
            end
            if iscell(NextQueueObj)
                if length(NextQueueObj)==1
                    obj.QueueObj(nIndex)=NextQueueObj;
                else
                    obj.QueueObj{nIndex}={NextQueueObj};
                end
            else
                obj.QueueObj{nIndex}=NextQueueObj;
            end
            obj.Listboxcontent{nIndex}=ShownContent;
            obj.Listboxhandle.String=obj.Listboxcontent;
        end
        
        function QueueObjElement=ReadQueue(obj,nIndex)
            % if nIndex=[], use listbox.Value (seleted one)
            if isempty(nIndex)
                nIndex=obj.Listboxhandle.Value;
            end
            if nIndex>length(obj.QueueObj)
                QueueObjElement=NaN;
            else
                QueueObjElement=obj.QueueObj{nIndex};
            end
        end
        
        function DeleteQueue(obj,nIndex)
            % if nIndex=[], use listbox.Value (seleted one)
            if isempty(nIndex)
                nIndex=obj.Listboxhandle.Value;
            end
            obj.Listboxcontent(nIndex)=[];
            obj.Listboxhandle.Value=max(min(nIndex)-1,1);
            obj.Listboxhandle.String=obj.Listboxcontent;
            obj.nListboxentry=obj.nListboxentry-length(nIndex);
            obj.QueueObj(nIndex)=[];
        end
        
        function ClearQueue(obj)
            DeleteQueue(obj,1:obj.nListboxentry);
        end
        
        function AppendText(obj,text)
            obj.nListboxentry=obj.nListboxentry+1;
            obj.Listboxcontent(obj.nListboxentry)={text};
            set(obj.Listboxhandle,'String',obj.Listboxcontent);
        end
        
        function ReturnQueueObj=GetQueueObj(obj,nIndex,bDelete)
            % if nIndex=[], use listbox.Value (seleted one)
            % if bDelete, delete the queueobj and return it; otherwise just
            % set listbox value to the next one
            if isempty(nIndex)
                nIndex=obj.Listboxhandle.Value;
            end
            ReturnQueueObj=obj.QueueObj{nIndex};
            if bDelete
                DeleteQueue(obj,nIndex);
            else
                obj.Listboxhandle.Value=nIndex+1;
            end
        end
        
        function SwapOrder(obj,n1,n2)
            % if n1=[], use listbox.Value (seleted one)
            % if n2=-1 or 0, use n1-1 or n1+1
            if isempty(n1)
                n1=obj.Listboxhandle.Value;
            end
            if n2==-1
                n2=n1-1;
            elseif n2==0
                n2=n1+1;
            end
            tmp=obj.QueueObj(n1);
            tmp2=obj.Listboxcontent(n1);
            obj.QueueObj(n1)=obj.QueueObj(n2);
            obj.QueueObj(n2)=tmp;
            
            obj.Listboxcontent(n1)=obj.Listboxcontent(n2);
            obj.Listboxcontent(n2)=tmp2;
            obj.Listboxhandle.String(n1)=obj.Listboxhandle.String(n2);
            obj.Listboxhandle.String(n2)=tmp2;
            
            obj.Listboxhandle.Value=n2;
        end
        
        function str=formatVectorString(obj,DoubleVector,nIndex)
           % input: [1,2,3] (double vector)
           % output '[1,2,3]' (string)
           % if nIndex is given, put '#2:' in front.
           str='[';
           for i=1:length(DoubleVector)
               str=[str,num2str(DoubleVector(i)) ', '];
           end
           str=[str(1:end-2) ']'];
           if nargin==3
               strPrefix=['#' int2str(nIndex) ': '];
               if nIndex<10
                   strPrefix=[strPrefix,' '];
               end
               str=[strPrefix,str];
           end
        end
    end
    
    methods (Access=private)
        function ListboxInit(obj)
            
        end
    end
end