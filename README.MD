<h1>KeyPress OSD: Presentation</h1>

<h2><a href="https://www.youtube.com/watch?v=LKvhqTeb9sg">Presentation video</a></h2>
<h2>To keep the development going, <a href="https://www.paypal.me/MariusSucan/15">please donate</a> using PayPal.</h2>
<h2>Please <a href="https://www.paypal.me/MariusSucan/15">check the commercial edition</a> as well.</h2>

<p>This program is an On-Screen Display or a Heads-Up Display for keys. It displays every key or mouse button press at a clearly visible text size. I developed it for people like me, with poor eye sight or low vision. It is meant to aid desktop computer usage. It is especially useful while chatting or for occasional typing. The user no longer has to squint at the screen or zoom in the entire screen to see what s/he wrote for every text field.</p>

<p>This application can also be used for screen casts or presentations, by disabling the typing mode at Preferences. In its main menu, you can select Quick Start Presets to help you get started.</p>

<p>Numerous unique features, options and settings are available in the different Preferences windows provided in the program, such that everyone can find a way to adapt it to personal needs.</p>

<p>This application has support for Cyrillic and Latin-based keyboard layouts. I also did some limited testing with Indic  layouts, e.g., Bengali, and as far as I can tell, KeyPress OSD works with these as well.</p>

<p>In recent versions, I implemented partial support for Right-to-Left [RTL] keyboard layouts, such as Arabic. Caret navigation is disabled for such layouts.</p>

<p>I did not test or developed this application having in mind support for Chinese or Japanese scripts. It would be too complex for me to implement support for such writing systems. On Windows, to type in such languages one makes use of IMEs [Input Method Editors] - additional typing aids that facilitate input of non-Latin texts using Latin keyboards.</p>

<p>If other programmers are willing to invest time in this application and to extend it, are welcomed to do so. Anyone is free to transform it into anything they wish. The source code is available. However, keep in mind, I am no programmer. I learned to code by developing this application. The code quality is definitely poor :-).</p>

<p>I coded the application as an <a href="https://autohotkey.com/">AHK script</a> for AutoHotkey_H v1.1.27. To execute/compile the source code one needs <a href="https://hotkeyit.github.io/v2/">AutoHotkey_H v1.1+</a>.</p>
<p>Through the development of this project, Drugwash (from the <a href="https://autohotkey.com/boards/">AHK forums</a>) substantially contributed with code and feedback. Many thanks to you!</p>
<p>In addition, many thanks for the great support and help to the people on #ahk (irc.freenode.net) and from the AHK forum.</p>


<h1>KeyPress OSD: Features</h1>

<ul>
<li>Support for at least 110 keyboard layouts covering about 55 languages. It recognizes keys with Shift, AltGr and dead keys for each of these layouts.</li>
<li>Automatic detection of keyboard layouts.</li>
<li>Show previously pressed key if fired quickly.</li>
<li>Count key presses or key fires and mouse clicks.</li>
<li>Indicators for Caps Lock, Num Lock and Scroll Lock states.</li>
<li>Typing mode. It shows what you are typing in an expanding text area.</li>
<li>Virtual caret/cursor navigation: </li>
<ul>
  <li>Navigate through typed text in the OSD in synch with the text field of the host application.</li>
  <li>Basic support for copy, paste, cut and undo with Ctrl + A / Z / X / C / V.</li>
  <li>Support for text selections.</li>
  <li>Support for customizable automatic text expansion, e.g, 'btw' expands to 'by the way', or 'bbl' to 'be back later'.</li>
  <li>Multi-Clipboard support. You can easily retrieve previous clipboard contents and text typed in the OSD. The texts stored in the clipboards retain their formatting.</li>
  <li>Shortcuts to copy the text from the active text field into the OSD, or paste the OSD content to it.</li>
</ul> 

<li>Only typing mode option.</li>
<li>Typed text history with Page Up/Down. On pressing Enter or Escape, it records the written line and you can get back to it with Page Up.</li>
<li>Automatic resizing of OSD/HUD or fixed size.</li>
<li>Customizable size, position and colors.</li>
<li>The OSD can hide or switch position automatically when the mouse runs over it.</li>
<li>Customizable visual mouse clicks and mouse halo to indicate its location, and flash mouse cursor after idling.</li>
<li>Mouse keys. Move the mouse cursor with the numpad keys.</li>
<ul>
  <li>Ability to lock Left, Right and Middle clicks to facilitate drag-n-drop operations, using ScrollLock or numpad Enter.</li>
  <li>Option to wrap / warp mouse movements at screen edges.</li>
  <li>Ability to move in 16 different directions by combining two directions simultaneously.</li>
  <li>Ease to alternate between cursor speeds using Capslock.</li>
</ul>
<li>Distinct beepers for different types of keys and buttons or when typing with Capslock.</li>
<li>Clipboard monitor. It displays briefly texts copied to clipboard.</li>
<li>Multi-monitor support.</li>
<li>Portable. No need to install/uninstall. Settings stored in an easy to read INI file.</li>
<li>Easy to configure with many options in Settings windows to toggle features and customize behavior and look.</li>
<li>Option to update to the latest version.</li>
</ul>
