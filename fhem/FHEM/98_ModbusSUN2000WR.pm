##############################################
# $Id: 98_ModbusSUN2000WR.pm
# module generated automatically by ModbusAttr
#
#  Storage-Location on FHEM-Server: /opt/fhem/FHEM/98_ModbusSUN2000WR.pm
#
##############################################################################
#  Changelog:
#  2022-10-14  initial release from: https://forum.fhem.de/index.php/topic,115422.msg1239637.html#msg1239637
#  2023-03-10  took the initial release and adapted it for my use
#  2023-05-22  generated this module by 'set mdbsWR saveAsModule ModbusSUN2000WR' and adapted the generated module - Robert
#  2023-10-24  added some readings for battery - passibe
#  2024-02-14  added some settings for battery

package main;

use strict;
use warnings;
use Time::HiRes qw( time );

sub ModbusSUN2000WR_Initialize($);

# deviceInfo defines properties of the device.
# some values can be overwritten in parseInfo, some defaults can even be overwritten by the user with attributes if a corresponding attribute is added to AttrList in _Initialize.

my %ModbusSUN2000WR_deviceInfo = (
         "timing" =>  {        timeout => 3,    # 3 seconds timeout when waiting for a response (can be overwritten with attribute dev-timing-timeout)
                             commDelay => 0.7,  # 0.7 seconds minimal delay between two communications e.g. a read and the next write,
                                                # can be overwritten with attribute commDelay if added to AttrList in _Initialize below or with attribute dev-timing-commDelay
                             sendDelay => 0.7,  # 0.7 seconds minimal delay between two sends, can be overwritten with the attribute
                                                # sendDelay if added to AttrList in _Initialize function below or with attribute dev-timing-sendDelay
                      },
              "h" =>  {           read => 3,    # use function code 3 to read holding registers (=default).
                                 write => 6,    # use function code 6 to write holding registers (=default). (code 16 can be used for writing to multiple holding registers)
                               defPoll => 1,    # All defined Input Registers should be polled by default unless specified otherwise in parseInfo or by attributes
                            defShowGet => 1,    # default fuer showget Key in parseInfo
                                defLen => 2,    # default length (number of registers) per value (e.g. 2 for a float of 4 bytes that spans 2 registers)
                             defUnpack => "N!", # default pack / unpack code to convert raw values, e.g. "N!" for a signed long (32-bit) (http://perldoc.perl.org/functions/pack.html
                      }
);

# %parseInfo:
# r/c/i+adress => objHashRef (h = holding register, c = coil, i = input register, d = discrete input)
# the address is a decimal number without leading 0
#
# Explanation of the parseInfo hash sub-keys:
# name          internal name of the value in the modbus documentation of the physical device
# reading       name of the reading to be used in Fhem
# set           can be set to 1 to allow writing this value with a Fhem set-command
# setmin        min value for input validation in a set command
# setmax        max value for input validation in a set command
# hint          string for fhemweb to create a selection or slider
# expr          perl expression to convert a string after it has bee read
# map           a map string to convert an value from the device to a more readable output string 
#               or to convert a user input to the machine representation
#               e.g. "0:mittig, 1:oberhalb, 2:unterhalb"
# setexpr       per expression to convert an input string to the machine format before writing
#               this is typically the reverse of the above expr
# format        a format string for sprintf to format a value read
# len           number of Registers this value spans
# poll          defines if this value is included in the read that the module does every defined interval
#               this can be changed by a user with an attribute
# unpack        defines the translation between data in the module and in the communication frame
#               see the documentation of the perl pack function for details.
#               example: "n" for an unsigned 16 bit value or "f>" for a float that is stored in two registers
# showget       can be set to 1 to allow a Fhem get command to read this value from the device
# polldelay     if a value should not be read in each iteration after interval has passed, 
#               this value can be set to a multiple of interval

my %ModbusSUN2000WR_parseInfo = (
         "h30000" =>  {           expr => 'substr($val,0,16)',
                                   len => 15,
                             polldelay => "x180",
                               reading => "WR_Modell_Name",
                                unpack => "a*",
                      },
         "h30015" =>  {            len => 15,
                             polldelay => "x180",
                               reading => "WR_Modell_SN",
                                unpack => "a*",
                      },
         "h30025" =>  {            len => 10,
                             polldelay => "x180",
                               reading => "WR_Modell_PN",
                                unpack => "a*",
                      },
         "h30070" =>  {            len => 1,
                             polldelay => "x180",
                               reading => "WR_Modell_ID",
                                unpack => "n",
                      },
         "h30071" =>  {            len => 1,
                             polldelay => "x180",
                               reading => "WR_Anzahl_PVStrings",
                                unpack => "n",
                      },
         "h30072" =>  {            len => 1,
                             polldelay => "x180",
                               reading => "WR_Anzahl_MPPTrackers",
                                unpack => "n",
                      },
         "h30073" =>  {           expr => '$val/1000',
                                   len => 2,
                             polldelay => "x180",
                               reading => "WR_Leistung_Nenn",
                                unpack => "N",
                      },
         "h32000" =>  {           expr => 'sprintf( "0b%010b",$val )',
                                   len => 1,
                               reading => "A_Status_1",
                                unpack => "n",
                      },
         "h32002" =>  {           expr => 'sprintf( "0b%03b",$val )',
                                   len => 1,
                               reading => "A_Status_2",
                                unpack => "n",
                      },
         "h32003" =>  {           expr => 'sprintf( "0b%02b",$val )',
                                   len => 2,
                               reading => "A_Status_3",
                                unpack => "N",
                      },
         "h32008" =>  {           expr => 'sprintf( "0b%016b",$val )',
                                   len => 1,
                               reading => "A_Alarm_1",
                                unpack => "n",
                      },
         "h32009" =>  {           expr => 'sprintf( "0b%016b",$val )',
                                   len => 1,
                               reading => "A_Alarm_2",
                                unpack => "n",
                      },
         "h32010" =>  {           expr => 'sprintf( "0b%014b",$val )',
                                   len => 1,
                               reading => "A_Alarm_3",
                                unpack => "n",
                      },
         "h32016" =>  {           expr => '$val/10',
                                   len => 1,
                               reading => "WR_Spannung_String1",
                                unpack => "n!",
                      },
         "h32017" =>  {           expr => '$val/100',
                                   len => 1,
                               reading => "WR_Strom_String1",
                                unpack => "n!",
                      },
         "h32018" =>  {           expr => '$val/10',
                                   len => 1,
                               reading => "WR_Spannung_String2",
                                unpack => "n!",
                      },
         "h32019" =>  {           expr => '$val/100',
                                   len => 1,
                               reading => "WR_Strom_String2",
                                unpack => "n!",
                      },
         "h32064" =>  {            len => 2,
                               reading => "WR_Leistung_EingangSolar_W",
                                unpack => "N!",
                      },
         "h32069" =>  {           expr => '$val/10',
                                   len => 1,
                               reading => "WR_Spannung_A",
                                unpack => "n",
                      },
         "h32070" =>  {           expr => '$val/10',
                                   len => 1,
                               reading => "WR_Spannung_B",
                                unpack => "n",
                      },
         "h32071" =>  {           expr => '$val/10',
                                   len => 1,
                               reading => "WR_Spannung_C",
                                unpack => "n",
                      },
         "h32072" =>  {           expr => '$val/1000',
                                   len => 2,
                               reading => "WR_Strom_A",
                                unpack => "N!",
                      },
         "h32074" =>  {           expr => '$val/1000',
                                   len => 2,
                               reading => "WR_Strom_B",
                                unpack => "N!",
                      },
         "h32076" =>  {           expr => '$val/1000',
                                   len => 2,
                               reading => "WR_Strom_C",
                                unpack => "N!",
                      },
         "h32078" =>  {            len => 2,
                               reading => "WR_Leistung_Tagesspitze_W",
                                unpack => "N!",
                      },
         "h32080" =>  {            len => 2,
                               reading => "WR_Leistung_Momentan_W",
                                unpack => "N!",
                      },
         "h32086" =>  {           expr => '$val/100',
                                   len => 1,
                               reading => "WR_Effizienz",
                                unpack => "n",
                      },
         "h32087" =>  {           expr => '$val/10',
                                   len => 1,
                               reading => "WR_Temperatur_Intern",
                                unpack => "n!",
                      },
         "h32089" =>  {            len => 1,
                                   map => "0:standby_0, 1:standby_1, 2:standby_2, 3:standby_3, 256:starting, 512:on_grid, 513:power_limited, 514:self_derating, 768:shutdown_fault, 769:shutdown_command, 770:shutdown_OVGR, 771:shutdown_comm_disconn, 772:shutdown_power_limited, 773:shutdown_manual_startup_required, 774:shutdown_DC_switches_disconn, 775:shutdown_rapid_cutoff, 776:shutdown_input_underpower, 1025:Grid_scheduling_cosf-P_curve, 1026:Grid_scheduling_Q-U_curve, 1027:Grid_scheduling_PF-U_curve, 1028:Grid_scheduling_dry_contact, 1029:Grid_scheduling_Q-P_curve, 1280:Spot-check_ready, 1281:Spot-checking, 1536:Inspecting, 1792:AFCI_self_check, 2048:I-V_scanning, 2304:DC_input_detection, 2560:Running_off-grid_charging, 40960:Standby_no_irradiation",
                               reading => "WR_Geraetestatus",
                                unpack => "n",
                      },
         "h32091" =>  {           expr => 'strftime("%Y-%m-%d %H:%M:%S",gmtime($val))',
                                   len => 2,
                             polldelay => "x180",
                               reading => "WR_Zeit_Startup",
                                unpack => "N",
                      },
         "h32093" =>  {           expr => 'strftime("%Y-%m-%d %H:%M:%S",gmtime($val))',
                                   len => 2,
                             polldelay => "x180",
                               reading => "WR_Zeit_Shutdown",
                                unpack => "N",
                      },
         "h32106" =>  {           expr => 'sprintf( "%.2f", $val/100 )',
                                   len => 2,
                               reading => "WR_Energie_PV_Gesamt_kWh",
                                unpack => "N",
                      },
         "h32114" =>  {           expr => 'sprintf( "%.2f", $val/100 )',
                                   len => 2,
                               reading => "WR_Energie_PV_Tag_kWh",
                                unpack => "N",
                      },
         "h37100" =>  {            len => 1,
                                   map => "0:offline, 1:normal",
                               reading => "PM_Status",
                                unpack => "n",
                      },
         "h37101" =>  {           expr => '$val/10',
                                   len => 2,
                               reading => "PM_Spannung_Netz_A",
                                unpack => "N!",
                      },
         "h37103" =>  {           expr => '$val/10',
                                   len => 2,
                               reading => "PM_Spannung_Netz_B",
                                unpack => "N!",
                      },
         "h37105" =>  {           expr => '$val/10',
                                   len => 2,
                               reading => "PM_Spannung_Netz_C",
                                unpack => "N!",
                      },
         "h37107" =>  {           expr => '$val/100',
                                   len => 2,
                               reading => "PM_Strom_Netz_A",
                                unpack => "N!",
                      },
         "h37109" =>  {           expr => '$val/100',
                                   len => 2,
                               reading => "PM_Strom_Netz_B",
                                unpack => "N!",
                      },
         "h37111" =>  {           expr => '$val/100',
                                   len => 2,
                               reading => "PM_Strom_Netz_C",
                                unpack => "N!",
                      },
         "h37113" =>  {            len => 2,
                               reading => "PM_Leistung_Momentan_W",
                                unpack => "N!",
                      },
         "h37117" =>  {           expr => '$val/1000',
                                   len => 1,
                               reading => "PM_Leistungsfaktor",
                                unpack => "n!",
                      },
         "h37118" =>  {           expr => '$val/100',
                                   len => 1,
                               reading => "PM_Netzfrequenz",
                                unpack => "n!",
                      },
         "h37119" =>  {           expr => 'sprintf( "%.2f", $val/100 )',
                                   len => 2,
                               reading => "PM_Energie_insNetz_Gesamt_kWh",
                                unpack => "N!",
                      },
         "h37121" =>  {           expr => 'sprintf( "%.2f", $val/100 )',
                                   len => 2,
                               reading => "PM_Energie_vomNetz_Gesamt_kWh",
                                unpack => "N!",
                      },
         "h37132" =>  {            len => 2,
                               reading => "PM_Leistung_A_W",
                                unpack => "N!",
                      },
         "h37134" =>  {            len => 2,
                               reading => "PM_Leistung_B_W",
                                unpack => "N!",
                      },
         "h37136" =>  {            len => 2,
                               reading => "PM_Leistung_C_W",
                                unpack => "N!",
                      },
         "h40000" =>  {           expr => 'strftime("%Y-%m-%d %H:%M:%S",gmtime($val))',
                                   len => 2,
                                   max => 3155759999,
                                   min => 946684800,
                               reading => "WR_Zeit_System",
                                   set => 1,
                                unpack => "N",
                      },
         "h40200" =>  {            len => 1,
                                   max => 1,
                                   min => 0,
                             polldelay => "once",
                               reading => "WR_Startup",
                                   set => 1,
                                unpack => "n",
                      },
         "h40201" =>  {            len => 1,
                                   max => 1,
                                   min => 0,
                             polldelay => "once",
                               reading => "WR_Shutdown",
                                   set => 1,
                                unpack => "n",
                      },
         "h42000" =>  {            len => 1,
                                   map => "0:Germany, 255:Austria, 256:Austria-MV480, 267:Europa",
                                   max => 275,
                                   min => 0,
                             polldelay => "x180",
                               reading => "WR_Netzcode",
                                   set => 1,
                                unpack => "n",
                      },
         "h43006" =>  {            len => 1,
                                   max => 840,
                                   min => -720,
                             polldelay => "x180",
                               reading => "WR_Zeitzone",
                                   set => 1,
                                unpack => "n!",
                      },
         "h47415" =>  {            len => 1,
#                                   map => "0:unlimited, 1:DI_active_scheduling, 5:zero_power_grid_connection, 6:power_limited_grid_connection_kw, 7:power_limited_grid_connection_percent",
                                   map => "0:Netzanschluss_Begrenzung_keine, 1:Netzanschluss_Begrenzung_Fernsteuerung, 5:Netzanschluss_Begrenzung_total, 6:Netzanschluss_Begrenzung_kw, 7:Netzanschluss_Begrenzung_Prozent",
                                   max => 7,
                                   min => 0,
                             polldelay => "x30",
                               reading => "WR_Leistungsbegrenzung_Modus",
                                   set => 1,
                                unpack => "n",
                      },
         "h47416" =>  {           expr => '$val/1000',
                                   len => 2,
                                   max => 10,
                                   min => -1000,
                             polldelay => "x30",
                               reading => "WR_Leistungsbegrenzung_kW",
                                   set => 1,
                               setexpr => '$val*1000',
                                unpack => "N!",
                      },
         "h47418" =>  {           expr => '$val/10',
                                   len => 1,
                                   max => 100,
                                   min => 0,
                             polldelay => "x30",
                               reading => "WR_Leistungsbegrenzung_Prozent",
                                   set => 1,
                               setexpr => '$val*10',
                                unpack => "n!",
                      },
         "h47087" =>  {            len => 1,
                                   map => "0:off, 1:on",
                               reading => "BAT_Netzladen",
                                   set => 1,
                                unpack => "n",
                      },
         "h47081" =>  {           expr => '$val/10',
                                   len => 1,
                                   max => 100,
                                   min => 90,
                             polldelay => "x30",
                               reading => "BAT_Max_SOC",
                                   set => 1,
                               setexpr => '$val*10',
                                unpack => "n",
                      },
         "h47082" =>  {           expr => '$val/10',
                                   len => 1,
                                   max => 50,
                                   min => 0,
                             polldelay => "x30",
                               reading => "BAT_Min_SOC",
                                   set => 1,
                               setexpr => '$val*10',
                                unpack => "n",
                      },
         "h47075" =>  {            len => 2,
                                   max => 5000,
                                   min => 0,
                             polldelay => "x30",
                               reading => "BAT_Max_Ladeleistung",
                                   set => 1,
                                unpack => "N",
                      },
         "h47077" =>  {            len => 2,
                                   max => 5000,
                                   min => 0,
                             polldelay => "x30",
                               reading => "BAT_Max_Entladeleistung",
                                   set => 1,
                                unpack => "N",
                      },
         "h47084" =>  {            len => 2,
                                   max => 5000,
                                   min => 0,
                             polldelay => "x30",
                               reading => "BAT_Max_Erzw_Ladeleistung",
                                   set => 1,
                                unpack => "n!",
                      },
         "h47086" =>  {            len => 1,
                                   map => "0:Adaptiv_Max_Eigenverbrauch, 1:Fix_Lade_Entlade, 2:Max_Eigenverbrauch, 3:Zeitgesteuert_LG, 4:Max_Einspeisen, 5:Zeitgesteuert_Luna",
                                   max => 5,
                                   min => 0,
                             polldelay => "x30",
                               reading => "BAT_Arbeitsmodus",
                                   set => 1,
                                unpack => "n",
                      },
         "h47100" =>  {            len => 1,
                                   map => "0:Stop, 1:Laden, 2:Entladen",
                                   max => 2,
                                   min => 0,
                             polldelay => "x30",
                               reading => "BAT_Erzwinge",
                                   set => 1,
                                unpack => "n",
                      },
         "h47101" =>  {           expr => '$val/10',
                                   len => 1,
                                   max => 100,
                                   min => 0,
                             polldelay => "x30",
                               reading => "BAT_Ziel_SOC",
                                   set => 1,
                               setexpr => '$val*10',
                                unpack => "n",
                      },
         "h37000" =>  {            len => 1,
                                   map => "0:offline, 1:standby, 2:running, 3:fault, 4:sleep_mode",
                               reading => "BAT_Geraetestatus",
                                unpack => "n",
                      },
         "h37001" =>  {           expr => 'my $newval = $val == 2147483647 ? 0 : $val; return $newval',
                                   len => 2,
                               reading => "BAT_Leistung_W",
                                unpack => "N!",
                      },
         "h37004" =>  {           expr => 'sprintf( "%.2f", ($val==65535 ? 0 : $val/10))',   
				   len => 1,
                               reading => "BAT_Ladestand",
                                unpack => "n",
                      },
         "h37015" =>  {           expr => '$val/100',   
				   len => 2,
                               reading => "BAT_Tag_Ladung_kWh",
                                unpack => "N",
                      },
         "h37017" =>  {           expr => '$val/100',   
				   len => 2,
                               reading => "BAT_Tag_Entladung_kWh",
                                unpack => "N",
                      },
         "h37066" =>  {           expr => '$val/100',   
				   len => 2,
                               reading => "BAT_Gesamt_Ladung_kWh",
                                unpack => "N",
                      },
         "h37068" =>  {           expr => '$val/100',   
				   len => 2,
                               reading => "BAT_Gesamt_Entladung_kWh",
                                unpack => "N",
                      }
# Ende parseInfo
);

#####################################
sub ModbusSUN2000WR_Initialize($) {
    my ($modHash) = @_;

    # https://forum.fhem.de/index.php/topic,75638.msg1263471.html#msg1263471
    #require "$attr{global}{modpath}/FHEM/98_Modbus.pm";
    LoadModule "Modbus";

    $modHash->{parseInfo}  = \%ModbusSUN2000WR_parseInfo;   # defines registers, inputs, coils etc. for this Modbus Device
    $modHash->{deviceInfo} = \%ModbusSUN2000WR_deviceInfo;  # defines properties of the device like defaults and supported function codes

    ModbusLD_Initialize($modHash);                          # Generic function of the Modbus module does the rest
    
    $modHash->{AttrList} = $modHash->{AttrList} . " " .     # Standard Attributes like IODEv etc 
        $modHash->{ObjAttrList} . " " .                     # Attributes to add or overwrite parseInfo definitions
        $modHash->{DevAttrList} . " " .                     # Attributes to add or overwrite devInfo definitions
        "poll-.* " .                                        # overwrite poll with poll-ReadingName
        "polldelay-.* ";                                    # overwrite polldelay with polldelay-ReadingName
}

1;

=pod
=begin html

<a name="ModbusSUN2000WR"></a>
<h3>ModbusSUN2000WR</h3>
<ul>
	ModbusSUN2000WR uses the low level Modbus module to provide a way to communicate with the Huawei SUN2000-10KTL-M1 inverter.
	It defines the modbus holding registers and reads them in a defined interval.

	<br>
	<b>Prerequisites</b>
	<ul>
		<li>
			This module requires the basic Modbus module which itself requires Device::SerialPort or Win32::SerialPort module.
		</li>
	</ul>
	<br>

	<a name="ModbusSUN2000WRDefine"></a>
	<b>Define</b>
	<ul>
		<code>define &lt;name&gt; ModbusSUN2000WR &lt;Id&gt; &lt;Interval&gt; &lt;IP-Address:Port&gt; &lt;RTU|ASCII|TCP&gt;</code>
		<br><br>
		The module connects to the Huawei SUN2000-10KTL-M1 inverter with Modbus Id &lt;Id&gt; through an already defined modbus device and actively requests data from the 
		inverter every &lt;Interval&gt; seconds <br>
		<br>
		Example:<br>
		<br>
		<ul><code>define mdbsWR ModbusSUN2000WR 0 60 192.168.1.103:6607 TCP</code></ul>
	</ul>
	<br>

	<a name="ModbusSUN2000WRConfiguration"></a>
	<b>Configuration of the module</b><br><br>
	<ul>
		apart from the modbus id and the interval which both are specified in the define command there is nothing that needs to be defined.
		However there are some attributes that can optionally be used to modify the behavior of the module. <br><br>

		The attributes that control which messages are sent / which data is requested every &lt;Interval&gt; seconds are:

		<pre>
		poll-PM_Energie_insNetz_Gesamt_kWh
		poll-PM_Energie_vomNetz_Gesamt_kWh
		</pre>

		if the attribute is set to 1, the corresponding data is requested every &lt;Interval&gt; seconds. If it is set to 0, then the data is not requested.
		by default the temperatures are requested if no attributes are set.
		<br><br>
		Example:
		<pre>
		define mdbsWR ModbusSUN2000WR 0 60 192.168.1.103:6607 TCP
		attr mdbsWR poll-PM_Energie_vomNetz_Gesamt_kWh 0
		</pre>
	</ul>

	<a name="ModbusSUN2000WR"></a>
	<b>Set-Commands</b><br>
	<ul>
		The following set options are available:
		<br>
		if the attribute is set to 1, the corresponding data can be set to data individual value
		<br><br>
		Example:
		<pre>
		set mdbsWR WR_Leistungsbegrenzung_Modus 1
		</pre>
	</ul>
	<br>
	<a name="ModbusSUN2000WRGet"></a>
	<b>Get-Commands</b><br>
	<ul>
		All readings are also available as Get commands. Internally a Get command triggers the corresponding 
		request to the device and then interprets the data and returns the right field value. To avoid huge option lists in FHEMWEB, only the most important Get options
		are visible in FHEMWEB. However this can easily be changed since all the readings and protocol messages are internally defined in the modue in a data structure 
		and to make a Reading visible as Get option only a little option (e.g. <code>showget => 1</code> has to be added to this data structure
	</ul>
	<br>
	<a name="ModbusSUN2000WRattr"></a>
	<b>Attributes</b><br><br>
	<ul>
	<li><a href="#do_not_notify">do_not_notify</a></li>
		<li><a href="#readingFnAttributes">readingFnAttributes</a></li>
		<br>
		<li><b>poll-PM_Energie_insNetz_Gesamt_kWh</b></li> 
		<li><b>poll-PM_Energie_vomNetz_Gesamt_kWh</b></li> 
			include a read request for the corresponding registers when sending requests every interval seconds <br>
		<li><b>timeout</b></li> 
			set the timeout for reads, defaults to 3 seconds <br>
		<li><b>minSendDelay</b></li> 
			minimal delay between two requests sent to this device
		<li><b>minCommDelay</b></li> 
			minimal delay between requests or receptions to/from this device
	</ul>
	<br>
</ul>

=end html
=cut
