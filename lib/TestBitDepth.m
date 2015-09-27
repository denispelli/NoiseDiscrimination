% Test bit depth supported by display/video card
%
% Shows an intensity staircase from left to right, with starting intensity
% = mouse(y). If display supports the bit-depth tested (see divisor,
% below), then each step should be visible (super-threshold intensity
% staircase at bottom of screen shows the scale), esp. at low luminance. To
% further increase step visibility, 10hz flickering patches are added to
% each bar, at one intensity level higher than the bar.
% Alan Robinson, 6-2-2011

outputdevice = 'Native11Bit';
divisor = 2^11-1; % bitdepth to test 
screenNumber = 0; % which screen to use (0 = both OR just one display)

% you can select amongst all devices supported by PTB:
%
% 'None': Use standard 8 bit framebuffer, but
% disable the gamma correction provided by PTB's imaging pipeline. This is
% usually not what you want, but it allows to test how much faster the
% display runs without gamma correction.
%
% 'PseudoGray' - PseudoGray display, also known as "Bit stealing". This
% technique allows to create the perception of up to 1786 different
% luminance levels on standard 8 bit graphics hardware by use of some
% clever color rendering trick. See "help CreatePseudoGrayLUT" for
% references and details.
%
% 'Native10Bit' - Enables the native 10 bpc framebuffer support on ATI
% Radeon X1xxx / HDxxx GPU's when used under Linux or OS/X with the
% PsychtoolboxKernelDriver loaded (see "help PsychtoolboxKernelDriver" on
% how to do that). These GPU's do support 10 bits per color channel when
% this special mode is used. If you try this option on MS-Windows, or
% without the driver loaded or with a different GPU, it will just fail.
%
% 'VideoSwitcher' - Enable the Xiangrui Li et al. VideoSwitcher, a special
% type of video attenuator (see "help PsychVideoSwitcher") in standard
% "simple" mode.
%
% 'VideoSwitcherCalibrated' - Enable the Xiangrui Li et al. VideoSwitcher,
% but use the more complex (and more accurate?) mode with calibrated lookup
% tables (see "help PsychVideoSwitcher").
%
% 'Attenuator' - Enable support for standard Pelli & Zhang style video
% attenuators by use of lookup tables.
%
% Then we have support for the different modes of operation of the
% Cambridge Research Systems Bits++ box:
%
% 'Mono++' - Use 14 bit mono output mode, either with color index overlay
% (if the optional 2nd 'overlay' flag is set to 1, which is the default),
% or without color index overlay.
%
% 'Color++' - User 14 bits per color component mode.
%
% Then we have support for the different modes of operation of the
% VPixx Technologies DPixx (DataPixx) box:
%
% 'M16' - Use 16 bit mono output mode, either with color index overlay
% (if the optional 2nd 'overlay' flag is set to 1, which is the default),
% or without color index overlay.
%
% 'C48' - User 16 bits per color component mode.
%
% 'BrightSide' - Enable drivers for BrightSide's HDR display. This only
% works if you have a BrightSide HDR display + the proper driver libraries
% installed on MS-Windows. On other operating systems it just uses a simple
% dummy emulation of the display with less than spectacular results.
%
% 'DualPipeHDR' - Use experimental output to dual-pipeline HDR display
% device.

AssertOpenGL;

KbName('UnifyKeyNames');

esc = KbName('ESCAPE');
space = KbName('space');

try

	% Open a double-buffered fullscreen window with a gray (intensity =
	% 0.5) background and support for 16- or 32 bpc floating point framebuffers.
	PsychImaging('PrepareConfiguration');

 
	% This will try to get 32 bpc float precision if the hardware supports
	% simultaneous use of 32 bpc float and alpha-blending. Otherwise it
	% will use a 16 bpc floating point framebuffer for drawing and
	% alpha-blending, but a 32 bpc buffer for gamma correction and final
	% display. The effective stimulus precision is reduced from 23 bits to
	% about 11 bits when a 16 bpc float buffer must be used instead of a 32
	% bpc float buffer:
	PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

	switch outputdevice
		case {'Mono++'}
						 % Use Mono++ mode without color overlay:
				PsychImaging('AddTask', 'General', 'EnableBits++Mono++Output');
			

		case {'Color++'}
			% Use Color++ mode: We select averaging between even/odd
			% pixels, aka mode 2:
			PsychImaging('AddTask', 'General', 'EnableBits++Color++Output', 2);

		case {'M16'}

				% Use M16 mode of Datapixx without color overlay:
				PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');


		case {'C48'}
			% Use C48 mode of Datapixx: We select averaging between even/odd
			% pixels, aka mode 2:
			PsychImaging('AddTask', 'General', 'EnableDataPixxC48Output', 2);

		case {'Attenuator'}
			% Use the standard Pelli & Zhang style attenuator driver. This
			% uses a simple 3 row (for the three color channels Red, Green,
			% Blue) by n slots lookup table to map wanted intensity values
			% to RGB triplets for driving the attenuator. Any number of
			% slots up to 2^16 is supported, for a max precision of 16 bits
			% luminance. As we don't have a calibrated table in this demo,
			% we simply load a 2048 slot table (11 bit precision) with
			% random values:
			PsychImaging('AddTask', 'General', 'EnableGenericHighPrecisionLuminanceOutput', uint8(rand(3, 2048) * 255));


		case {'VideoSwitcher'}
			% Select simple opmode of VideoSwitcher, where only the btrr
			% blue-to-red ratio from the global configuration file is used
			% for calibrated output:
			PsychImaging('AddTask', 'General', 'EnableVideoSwitcherSimpleLuminanceOutput', [], 1);
			
			% Switch the device to high precision luminance mode:
			PsychVideoSwitcher('SwitchMode', screenNumber, 1);


		case {'VideoSwitcherCalibrated'}
			% Again the videoswitcher, but in lookup-table calibrated mode,
			% where additionally to the BTRR, a lookup table is loaded:
			PsychImaging('AddTask', 'General', 'EnableVideoSwitcherCalibratedLuminanceOutput', [], [], 1);
			
			% Switch the device to high precision luminance mode:
			PsychVideoSwitcher('SwitchMode', screenNumber, 1);

			
		case {'PseudoGray'}
			% Enable bitstealing aka PseudoGray shader:
			PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');

			
		case {'Native10Bit'}
			% Enable ATI GPU's 10 bit framebuffer under certain conditions
			% (see help for this file):
			PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');

		case {'Native11Bit'}
			% Enable ATI GPU's 11 bit framebuffer under certain conditions
			% (see help for this file):
			PsychImaging('AddTask', 'General', 'EnableNative11BitFramebuffer');

		case {'BrightSide'}
			% Enable drivers for BrightSide's HDR display:
			PsychImaging('AddTask', 'General', 'EnableBrightSideHDROutput');

			
	
		case {'None'}
			% No high precision output, just the plain 8 bit framebuffer,
			% even without gamma correction:
			PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');


		case {'DualPipeHDR'}
			% Enable experimental dual display, dual pipeline HDR output:
			
			% Handle single-screen vs. dual-screen output:
			if length(Screen('Screens')) == 1
				lrect = [0 0 600 600];
				rrect = [601 0 1201 600];
			end
			
			% Request actual output mode:
			PsychImaging('AddTask', 'General', 'EnableDualPipeHDROutput', min(Screen('Screens')), rrect);

		otherwise
			error('Unknown "outputdevice" provided.');
	end

	[w, wRect]=PsychImaging('OpenWindow',screenNumber, 0.5); % actually open the screen
	[width, height]=Screen('WindowSize', w);
   
	% Calibrated conversion driver for VideoSwitcher in use?
	if strcmp(outputdevice, 'VideoSwitcherCalibrated')
		% Tell the driver what luminance the background has. This allows
		% for some quite significant speedups in stimulus conversion:
		PsychVideoSwitcher('SetBackgroundLuminanceHint', w, 0.5);
	end
	
	% Animation loop:
	
	adder = 1;

	vbl = Screen('Flip', w);
   [d1 d2 keycode]=KbCheck;
		   
	while ~keycode(esc)
		adder = xor(adder,1);
		[x,y,buttons]=GetMouse(w);  % starting intensity set by mouse y
		[d1 d2 keycode]=KbCheck;
		
		 for i = 0:32:width % draw vertical stripes across screen, each 1/divisor greater than the last
			 Screen('FillRect', w, y/divisor, [i 0 i+32 height]);
			 Screen('FillRect', w, (y+adder)/divisor, [i+8 500 i+24 600]); % 10hz flicker 
			 Screen('FillRect', w, i/width/2, [i height-100 i+32 height]); % scale at bottom of screen
			 y = y + 1;
		 end
			  
	   vbl = Screen('Flip', w, vbl + 101/1000);  % Show stimulus after 110ms (assuming 100hz refresh)
	end
	  
	% We're done: Close all windows and textures:
	Screen('CloseAll');    
catch
	%this "catch" section executes in case of an error in the "try" section
	%above.  Importantly, it closes the onscreen window if its open.
	Screen('CloseAll');
	ShowCursor;
	psychrethrow(psychlasterror);
end %try..catch..

if ~isempty(findstr(outputdevice, 'VideoSwitcher'))
	% If VideoSwitcher was active, switch it back to standard RGB desktop
	% display mode:
	PsychVideoSwitcher('SwitchMode', screenNumber, 0);
end

% Restore gfx gammatables if needed:
RestoreCluts;