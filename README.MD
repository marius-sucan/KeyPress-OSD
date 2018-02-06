<h1>KeyPress OSD: Presentation</h1>

<p><a href="https://www.youtube.com/embed/_prbTMoUWug">Presentation video.</a></p>

<p>This program is an On-Screen Display or a Heads-Up Display for keys. It displays every key or mouse button press at a clearly visible text size. I developed it for people like me, with poor eye sight or low vision. It is meant to aid desktop computer usage. It is especially useful while chatting or for occasional typing. The user no longer has to squint at the screen or zoom in the entire screen to see what s/he wrote for every text field.</p>


<p>Numerous options and settings are available in the different Preferences windows provided in the program, such that everyone can find a way to adapt it to personal needs.</p>

<p>This application has support only for Cyrillic and Latin-based keyboards. I did not test or developed it having in mind support for Chinese, Arabic or Japanese scripts.</p>

<p>It is too complex for me to implement support for other alphabets or writing systems.</p>

<p>If other programmers are willing to invest time in this application and to extend it, are welcomed to do so. Anyone is free to transform it into anything they wish. The source code is available. However, keep in mind, I am no programmer. I learned to code just to develop this application. The code quality is definitely poor :-).</p>

<p>I coded the application as an <a href="https://autohotkey.com/">AHK script</a> for AutoHotkey_H v1.1. To execute/compile the source code one needs <a href="https://hotkeyit.github.io/v2/">AutoHotkey_H v1.1</a>.</p>

<p><em>Many thanks for the great support to drugwash</em> from the AHK forums and to the people on #ahk (irc.freenode.net), and all other people who offered me feedback or support during this project.</p>

<h1>KeyPress OSD: Features</h1>

<ul>
<li>Support for at least 110 keyboard layouts covering about 55 languages. It recognizes keys with Shift, AltGr and dead keys for each of these layouts.</li>
<li>Automatic detection of keyboard layouts.</li>
<li>Show previously pressed key if fired quickly.</li>
<li>Count key presses or key fires and mouse clicks.</li>
<li>Indicators for Caps Lock, Num Lock and Scroll Lock states.</li>
<li>Option to ignore specific keys.</li>
<li>Typing mode. It shows what you are typing in an expanding text area.</li>
<li>Virtual caret/cursor navigation: </li>
<ul>
  <li>Navigate through typed text in the OSD in synch with the text field of the host application.</li>
  <li>Basic support for copy, paste, cut and undo with Ctrl + A / Z / X / C / V.</li>
  <li>Support for text selections.</li>
  <li>Shortcuts to copy the text from the active text field into the OSD, or paste the OSD content to it.</li>
</ul> 

<li>Only typing mode option.</li>
<li>Typed text history with Page Up/Down. On pressing Enter or Escape, it records the written line and you can get back to it with Page Up.</li>
<li>Automatic resizing of OSD/HUD or fixed size.</li>
<li>Customizable size, position and colors.</li>
<li>Hides or switches position automatically when mouse runs over it.</li>
<li>Customizable visual mouse clicks and idle mouse highlighter.</li>
<li>Distinct beepers for different types of keys and buttons or when typing with Capslock.</li>
<li>Clipboard monitor. It displays briefly texts copied to clipboard.</li>
<li>Live text capture with Capture2Text (*)</li>
<li>Multi-monitor support.</li>
<li>Portable. No need to install/uninstall. Settings stored in an easy to read INI file.</li>
<li>Easy to configure with many options in Settings windows to toggle features and customize behavior and look.</li>
<li>Option to update to the latest version.</li>
</ul>
<p>(*) You must have Capture2Text running and Pause/Break set as a shortcut for "Text line capture". Copy to clipboard option must be enabled as well.</p>
<p>In this way, KeyPress OSD can continously display the texts detected by Capture2Text underneath the mouse cursor.</p>
