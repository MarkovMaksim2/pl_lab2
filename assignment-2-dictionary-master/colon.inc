%define ptr 0 

%macro colon 2
    %ifid %2
        %ifstr %1
        %2:
	    dq ptr
	    db %1, 0
        %else
            %error "First argument must be a string"
        %endif
    %else
        %error "Second argument must be a label"
    %endif

    %define ptr %2

%endmacro
