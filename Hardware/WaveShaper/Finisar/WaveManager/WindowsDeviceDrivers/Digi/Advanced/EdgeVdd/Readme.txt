
This file contains instructions for installing and configuring EdgeVDD.


EdgeVdd.DLL is a 'Virtual DOS Driver' for NT4.0, Windows 2000, and
Windows XP. This driver permits DOS applications to access Windows
COM ports above COM4 by implementing a virtual 16450 UART within
the DOS box for each Windows COM port configured by the user.

Currently, the driver does not come with an installation utility
and must be manually installed and configured, using the following
installation steps. Steps 2 and 3 can be automated somewhat with the
supplied Registry .INI file called "EdgeVdd.Ini".

1. Copy EDGEVDD.DLL into the %SystemRoot%\System32 directory. The
   supplied .INI file expects the file to be here. If you wish to
   run the DLL from a different directory, you must add a path to
   the string specified in step #2 below.

2. Update the following registry value to instruct Windows to load
   EDGEVDD.DLL whenever a new DOS box is created:

   Under the registry key:

	HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\VirtualDeviceDrivers

   there will be a REG_MULTI_SZ entry called 'VDD'. You must update
   this entry to contain the string "EdgeVdd.DLL". If you copied the
   EdgeVdd.DLL file to a different directory, add the path as part
   of this string.

3. Create registry entries to configure EdgeVDD COM port mappings.

   Under the registry key:

	HKEY_LOCAL_MACHINE\Software\Inside Out Networks\EdgeVdd\Ports

   you must create one or more REG_SZ entries named "COMx" which
   instruct EdgeVDD to map the given Windows COM port to the
   specified I/O port address and IRQ values within the DOS box.

   Each entry under ports should have the following value:

   <COMx> = REG_SZ "<UART base I/O port address>,<UART IRQ number>"

   Where <COMx> is the Windows name for the COM port, and the
   I/O port is specified in hex, and the IRQ number in decimal.

   For example,

   	COM5 = REG_SZ "100,5"

   would instruct EdgeVDD to create a virtual UART at I/O ports
   0100h through 0107h, using IRQ 5. This virtual UART would be
   mapped to the Windows COM5 port.


Instead of manually editing the registry, we have supplied a .INI
script file which may be used with the REGINI.EXE program from the
Windows NT/2000/XP Resource Kit. This .INI script is simply a text
file which may be edited with Notepad. The sample script creates
12 virtual UARTs, all using IRQ 5 and based at I/O ports from 0100h
through 0158h. The user should edit the script to correspond to
the actual COM ports available on the system and to the I/O port
and IRQ values expected by the DOS application(s).

Once the .INI script is edited, use the following command to place
the updated values into the registry:

	REGINI EdgeVdd.Ini

At this point, EdgeVdd.DLL will be loaded for each DOS session that
is created, and you should be ready to run DOS applications which
access the configured port(s).
