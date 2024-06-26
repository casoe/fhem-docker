########################################################################################
#
# RoombaUtils 
#
# Collection of various routines
# Prof. Dr. Peter A. Henning
# several contributions from hapege
#
# $Id: RoombaUtils.pm 2020-09- pahenning $
#
########################################################################################
#
#  This programm is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  The GNU General Public License can be found at
#  http://www.gnu.org/copyleft/gpl.html.
#  A copy is found in the textfile GPL.txt and important notices to the license
#  from the author is found in LICENSE.txt distributed with these scripts.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
########################################################################################

package main;

use strict;
use warnings;
use SetExtensions;

sub RoombaUtils_Initialize($$){

  my ($hash) = @_;

}

package roomba;
use strict;
use warnings;
use POSIX;
use Data::Dumper;
use JSON; 
use Math::Trig;
use Math::Trig ':pi';
use Math::Polygon::Calc;
use Math::ConvexHull qw/convex_hull/;
use Digest::MD5 qw(md5 md5_hex md5_base64);

#-- needed for catchall
use GPUtils qw(:all);
BEGIN {
  GP_Import(qw(
    json2nameValue
	))
};

my $roombaversion = "1.3";

my %roomba_transtable_EN = ();
my %roomba_transtable_DE = ();
my $roomba_tt;

my %roombaerrs_en = (
        0 => "None",
        1 => "Left wheel off floor",
        2 => "Main Brushes stuck",
        3 => "Right wheel off floor",
        4 => "Left wheel stuck",
        5 => "Right wheel stuck",
        6 => "Stuck near a cliff",
        7 => "Left wheel error",
        8 => "Bin error",
        9 => "Bumper stuck",
        10 => "Right wheel error",
        11 => "Bin error",
        12 => "Cliff sensor issue",
        13 => "Both wheels off floor",
        14 => "Bin missing",
        15 => "Reboot required",
        16 => "Bumped unexpectedly",
        17 => "Path blocked",
        18 => "Docking issue",
        19 => "Undocking issue",
        20 => "Docking issue",
        21 => "Navigation problem",
        22 => "Navigation problem", 
        23 => "Battery issue",
        24 => "Navigation problem",
        25 => "Reboot required",
        26 => "Vacuum problem",
        27 => "Vacuum problem",
        29 => "Software update needed",
        30 => "Vacuum problem",
        31 => "Reboot required",
        32 => "Smart map problem",
        33 => "Path blocked",
        34 => "Reboot required",
        35 => "Unrecognised cleaning pad",
        36 => "Bin full",
        37 => "Tank needed refilling",
        38 => "Vacuum problem",
        39 => "Reboot required",
        40 => "Navigation problem",
        41 => "Timed out",
        42 => "Localization problem",
        43 => "Navigation problem",
        44 => "Pump issue",
        45 => "Lid open",
        46 => "Low battery",
        47 => "Reboot required",
        48 => "Path blocked",
        52 => "Pad required attention",
        65 => "Hardware problem detected",
        66 => "Low memory",
        68 => "Hardware problem detected",
        73 => "Pad type changed",
        74 => "Max area reached",
        75 => "Navigation problem",
        76 => "Hardware problem detected"
    );           
  
my %roombaerrs_de = (
        0 => "Kein Fehler",
        1 => "Linkes Rad nicht am Boden",
        2 => "Hauptbürste steckt fest",
        3 => "Rechtes Rad nicht am Boden",
        4 => "Linkes Rad steckt fest",
        5 => "Right wheel stuck",
        6 => "Steckt am Abgrund fest",
        7 => "Fehler am linken Rad",
        8 => "Fehler am Staubbehälter",
        9 => "Fehler Stoßsensor",
        10 => "Fehler am rechten Rad",
        11 => "Fehler am Staubbehälter",
        12 => "Fehler Abgrundsensor",
        13 => "Beide Räder nicht am Boden",
        14 => "Staubbehäter fehlt",
        15 => "Neustart nötig",
        16 => "Kollision nicht erwartet",
        17 => "Pfad blockiert",
        18 => "Docking Problem",
        19 => "Undocking Problem",
        20 => "Docking Problem",
        21 => "Navigationsproblem",
        22 => "Navigationsproblem", 
        23 => "Batterieproblem",
        24 => "Navigationsproblem",
        25 => "Neustart nötig",
        26 => "Fehler Staubsauger",
        27 => "Fehler Staubsauger",
        29 => "Software Update nötig",
        30 => "Fehler Staubsauger",
        31 => "Neustart nötig",
        32 => "Problem bei der Kartenerstellung",
        33 => "Pfad blockiert",
        34 => "Neustart nötig",
        35 => "Nicht erkanntes Wischpad",
        36 => "Staubbehälter voll",
        37 => "Tank muss gefüllt werden",
        38 => "Fehler Staubsauger",
        39 => "Neustart nötig",
        40 => "Navigationsproblem",
        41 => "Zeitüberschreitung",
        42 => "Positionsfehler",
        43 => "Navigationsproblem",
        44 => "Fehler Pumpe",
        45 => "Deckel offen",
        46 => "Akkustand niedrig",
        47 => "Neustart nötig",
        48 => "Pfad blockiert",
        52 => "Pfadproblem",
        65 => "Hardwarefehler",
        66 => "Low memory",
        68 => "Hardwarefehler",
        73 => "Wischpad gewechselt",
        74 => "Maximale Fläche erreicht",
        75 => "Navigationsproblem",
        76 => "Hardwarefehler"
    );     
    
 my %roombastates_en = ("charge" => "Charge",
              "new" => "New Mission",
              "run" => "Mission",
              "resume" => "Running",
              "hmMidMsn" => "Recharge on Mission",
              "recharge" => "Recharge",
              "stuck" => "Stuck",
              "hmUsrDock" => "User Docking",
              "dock" => "Docking",
              "dockend" => "Docking - End Mission",
              "cancelled" => "Cancelled",
              "stop" => "Stopped",
              "pause" => "Paused",
              "hmPostMsn" => "End Mission");
                            
my %roombastates_de = ("charge" => "Ladung",
              "new" => "Neue Mission",
              "run" => "Mission",
              "resume" => "Mission",
              "hmMidMsn" => "Nachladung während Mission",
              "recharge" => "Nachladung",
              "stuck" => "Steckt fest",
              "hmUsrDock" => "Dockingbefehl",
              "dock" => "Docking",
              "dockend" => "Docking - Mission beendet",
              "cancelled" => "Abgebrochen",
              "stop" => "Angehalten",
              "pause" => "Pause",
              "hmPostMsn" => "Mission beendet",
              "Charged" => "Geladen");

  
##############################################################################
#
#  setList
#
##############################################################################

sub command($$@){
  my ($name,$cmd,@evt) = @_;
  my $hash = $main::defs{$name};
  $hash->{VERSION} = $roombaversion;
  #$hash->{FW_detailFn}  = "roomba::makeTable";
  #$hash->{FW_summaryFn} = "roomba::makeShort";
  if( $cmd eq "start"){
    my $iodev= $hash->{IODev}->{NAME};
    if(main::Value($iodev) ne "opened"){
      main::fhem("set $iodev connect");
      main::fhem("setreading $name cmPhaseE Delay");
      main::fhem("defmod delay$name at +00:00:10 set $name start");
      return undef;
    }
  }
  $cmd = 'cmd {"command": "'.$cmd.'", "time": '.time().', "initiator": "localApp"}';
  
  #-- language selection
  if( !defined($roomba_tt) ){
    #-- in any attribute redefinition readjust language
    my $lang = main::AttrVal("global","language","EN");
    if( $lang eq "DE"){
      $roomba_tt = \%roomba_transtable_DE;
    }else{
      $roomba_tt = \%roomba_transtable_EN;
    }
  }
  return $cmd;
}

sub setting($$$){
  my ($name,$key,$data) = @_;
  my $hash = $main::defs{$name};
  $hash->{helper}{setting} = $key;
  my (@evt,$val,$cmd);
  @evt = split(' ',$data);
  $val = (defined($evt[1]))?$evt[1]:"false";
  $cmd = 'delta {"state": {"'.$key.'":'.$val.'}}';
  return $cmd;
}

sub setsched($$$){
  my ($name,$day,$data) = @_;
  my @evt = split(' ',$data);
  my $time = (defined($evt[1]))?$evt[1]:"";
  
  my $oldsched = main::ReadingsVal($name,"progWeek","[Sun:none,Mon:none,Tue:none,Wed:none,Thu:none,Fri:none,Sat:none]");
  $oldsched    =~ tr/\"|\[|\]//d;
  my @asched   = split(',',$oldsched);
  my @astart   = ("none","none","none","none","none","none","none");
  my @ahours   = (0,0,0,0,0,0,0);
  my @amin     = (0,0,0,0,0,0,0);

  for (my $i=0;$i<7;$i++){
    if( $asched[$i] =~ /....none/){
      $astart[$i] = "none";
      $ahours[$i] = 0;
      $amin[$i]   = 0;
    }else{
      $astart[$i] = "start";
      $asched[$i] =~ /....(\d\d?):(\d\d)/;
      $ahours[$i] = $1;
      $amin[$i]   = $2;
    }
  }
  if( $time =~ /(\d\d?):(\d\d)/){
    $astart[$day] = "start";
    $ahours[$day] = $1;
    $amin[$day]   = $2;
  }else{
    $astart[$day] = "none";
    $ahours[$day] = 0;
    $amin[$day]   = 0;
  }
  #my $cmd    = 'delta {"state": {"cleanSchedule": {"cycle":["none","start","start","start","start","start","none"],"h":[9,15,16,16,16,14,9],"m":[0,0,30,30,30,30,0]}}}';
  my $cmd = 'delta {"state": {"cleanSchedule": {"cycle":["'.join('","',@astart).'"],"h":['.join(',',@ahours).'],"m":['.join(',',@amin).']}}}';
  return $cmd;
}

sub setsched2 ($$$){
  #my $cmd = 'delta {"state":{"cleanSchedule2":
  #  [{"enabled": true, "type": 0,
  #  "start": {"day": [2, 4, 6], "hour": 11, "min": 0},
  #  "cmd": {"command": "start", "ordered": 1, "pmap_id": "z....g",
  #  "regions": [{"region_id": "10", "type": "rid"},
  #  {"region_id": "6", "type": "rid"},
  #  {"region_id": "5", "type": "rid"},
  #  {"region_id": "8", "type": "rid"}],
  #  "user_pmapv_id": "2....7"}}]}}
  #
  my ($name,$which,$data) = @_;
  my @time;
  my @hour;
  my @min;
  my @days;
  my @daysnum;
  my @pMapId;
  my @userPmapvId;
  my $cmdpre = 'delta {"state": {"cleanSchedule2": [';
  my $cmdpost = ']}}';
  my @cmdsched="";
  my @cmdregs="";
  my @enabled = "";
  my @setenable = split(' ',$data);
  my $numofsched =  main::ReadingsVal($name,"NumOfSchedules","0");
  my @numofreg;
  my $cmd = $cmdpre;
  for (my $i=1; $i<=$numofsched; $i++) {
    if ($i==$which or $which=="all") {
    $enabled[$i] = $setenable[1];
    #main::Log 1,"[RoombaUtils] Schedule $i is $enabled[$i] with which $which";
    }
    else {
    $enabled[$i] = yesnotobool(main::ReadingsVal($name,"Schedule".$i."Enabled",undef));
    #main::Log 1,"[RoombaUtils] Schedule $i is $enabled[$i] with which $which";
    }
    @time = split(":",main::ReadingsVal($name,"Schedule".$i."Time",undef));
    $hour[$i] = $time[0];
    $min[$i] = $time[1];
    # strip leading zero, otherwise Roomba won't accept
    $min[$i] =~ s/^0//g;
    $days[$i] = main::ReadingsVal($name,"Schedule".$i."WeekDays",undef);
    $days[$i] =~ s/So/0/g;
    $days[$i] =~ s/Mo/1/g;
    $days[$i] =~ s/Di/2/g;
    $days[$i] =~ s/Mi/3/g;
    $days[$i] =~ s/Do/4/g;
    $days[$i] =~ s/Fr/5/g;
    $days[$i] =~ s/Sa/6/g;
    $pMapId[$i] = main::ReadingsVal($name,"Schedule".$i."PMapID",undef);
    $userPmapvId[$i] = main::ReadingsVal($name,"Schedule".$i."UserPMapvID",undef);
    #main::Log 1,"[RoombaUtils] Schedule $i, hour: $hour[$i], min: $min[$i], days: $days[$i], pMapID: $pMapId[$i], UserpMapvID: $userPmapvId[$i]";
    $numofreg[$i] = main::ReadingsVal($name,"Schedule".$i."NumOfRegions",undef);
    $cmdregs[$i]="";
    for ( my $j=1; $j<=$numofreg[$i]; $j++) {
      $cmdregs[$i] = $cmdregs[$i].'{"region_id": "'.main::ReadingsVal($name,"Schedule".$i."Region".$j,undef).'", "type": "rid"}';
      if ( $j < $numofreg[$i] ) {$cmdregs[$i] = $cmdregs[$i].', '}
    }
    $cmdsched[$i] = "";
    $cmdsched[$i] = '{"enabled": '.$enabled[$i].', "type": 0, "start": {"day": ['.$days[$i].'], "hour": '.$hour[$i].', "min": '.$min[$i].'}, "cmd": {"command": "start", "ordered": 1, "pmap_id": "'.$pMapId[$i].'", "regions": ['.$cmdregs[$i].'], "user_pmapv_id": "'.$userPmapvId[$i].'"}}';
    $cmd = $cmd.$cmdsched[$i];
    if ( $i < $numofsched ) {$cmd = $cmd.', '}
   
  }
 
  $cmd = $cmd.$cmdpost;
  main::Log 1,"[RoombaUtils] Command: $cmd";
  #return;
  return $cmd;  	
}

sub cleanRoom($$$) {
  my ($name,$levelName,$evt) = @_;
  my $hash = $main::defs{$name};

  my @evts = split(' ',$evt);

  my $pmapId = main::AttrVal($name, 'floor_'.$levelName.'_pMapId', '');
  my $userPmapvId = main::AttrVal($name, 'floor_'.$levelName.'_userPmapvId', '');

  my $regionString = '"regions": [';
  my $nrRegions = @evts;

  for(my $regIdx = 1; $regIdx < $nrRegions; $regIdx++){
    my $regionName = $evts[$regIdx];
    my $regionId = main::AttrVal($name, 'room_'.$regionName.'_id', '');
    my $regionType = main::AttrVal($name, 'room_'.$regionName.'_type', '');

    $regionString = $regionString.'{"region_id": "'.$regionId.'", "type": "'.$regionType.'"}';
    if ($regIdx +1 < $nrRegions) {
      $regionString = $regionString.',';
    }
  }
  $regionString = $regionString.']';

  my $cmdString = '{"command": "start", "pmap_id": "'.$pmapId.'", '.$regionString.', "user_pmapv_id": "'.$userPmapvId.'", "ordered": 1, "time": '.time().', "initiator": "localApp"}';
  main::Log 1,"[RoombaUtils] cleanRoom: $cmdString";
  my $cmd = 'cmd '.$cmdString;
  return $cmd;
}

sub createFloor($$) {
  my ($name, $evt) = @_;
  my $hash = $main::defs{$name};

  my @evts = split(' ',$evt);
  my $floorName = main::makeReadingName($evts[1]);
  my $pMapId = $evts[2];
  my $userPmapvId = $evts[3];

  my $attrName = 'floor_'.$floorName.'_label';
  main::addToDevAttrList($name, $attrName);
  $main::attr{$name}{$attrName} = $evts[1];

  $attrName = 'floor_'.$floorName.'_pMapId';
  main::addToDevAttrList($name, $attrName);
  $main::attr{$name}{$attrName} = $pMapId;

  $attrName = 'floor_'.$floorName.'_userPmapvId';
  main::addToDevAttrList($name, $attrName);
  $main::attr{$name}{$attrName} = $userPmapvId;
}

sub createRoom($$) {
  my ($name, $evt) = @_;
  my $hash = $main::defs{$name};

  my @evts = split(' ',$evt);
  my $roomName = main::makeReadingName($evts[1]);
  my $floor = $evts[2];
  my $roomId = $evts[3];
  my $roomType = $evts[4];

  my $attrName = 'room_'.$roomName.'_label';
  main::addToDevAttrList($name, $attrName);
  $main::attr{$name}{$attrName} = $evts[1];

  $attrName = 'room_'.$roomName.'_floor';
  main::addToDevAttrList($name, $attrName);
  $main::attr{$name}{$attrName} = $floor;

  $attrName = 'room_'.$roomName.'_id';
  main::addToDevAttrList($name, $attrName);
  $main::attr{$name}{$attrName} = $roomId;

  $attrName = 'room_'.$roomName.'_type';
  main::addToDevAttrList($name, $attrName);
  $main::attr{$name}{$attrName} = $roomType;
}
# /hapege

#############################################################################
#
#  helper
#
#############################################################################

sub numtobool($){
  my ($num) = @_;
  my $ret = (($num==1)?"true":"false");
  return $ret;
}

sub booltoyesno($){
  my ($num) = @_;
  my $ret = (($num==1)?"yes":"no");
  #$ret = $num;
  return $ret;
}

#############################################################################
#
#  status - does not work yet
#
#############################################################################

sub status($@){
  my ($name,@evt) = @_;
  
  my $cmd = 'delta {"binPause":true}';
  return $cmd;
}

#############################################################################
#
#  readingList
#
##############################################################################

sub reading($$){
  my ($name,$evt) = @_;
  
  #main::Log 1,"============> $evt";
  
  #-- signal and pose come every second or so, keep it short
  if( $evt =~ /state....reported....signal/){
    return signale($evt);
  }elsif( $evt =~ /state....reported....pose/){
    return pose($name,$evt);
  }
  
  #-- all the other stuff might come much less often
  my $dec   = decode_json($evt);
  my $staterep = $dec->{'state'}->{'reported'};
  my %ret  = ();
  my $hash = $main::defs{$name};
  my $key  = $hash->{helper}{setting};
  
  if( $evt =~ /cleanMissionStatus/){
    #main::Log 1,"[RoombaUtils] mission event ".$evt;
    my %mission = %{$staterep->{'cleanMissionStatus'}};
    mission($name,\%mission,\%ret);
  }
  
  if( $evt =~ /bbrun/){
    main::Log 1,"[RoombaUtils] mission event ".$evt;
    my %bbrun = %{$staterep->{'bbrun'}};
    bbrun($name,\%bbrun,\%ret);
  }
  
  if( $evt =~ /cleanSchedule(2?)/){
    #main::Log 1,"[RoombaUtils] schedule event ".$evt;
    #-- older devices
    if( !defined($1) || $1 ne "2" ){
      my %cleans = %{$staterep->{'cleanSchedule'}};
      schedule($name,\%cleans,\%ret);
    #-- for i7
    }elsif( defined($1) && $1 eq "2" ){
      my %cleana = %{$staterep};
      schedule2($name,\%cleana,\%ret);
    }
  }

  #-- getting events of the type
  # {"state":{"reported":{"vacHigh":false,"binPause":true,"carpetBoost":false,"openOnly":false,"twoPass":false,"schedHold":false,"lastCommand":{"command":"stop","time":1,"initiator":"localApp"}}}}
  if( $evt =~ /(vacHigh)|(openOnly)|(binPause)|(carpetBoost)|(twoPass)|(schedHold)|(lastCommand)/){
    my $vacH  = $staterep->{'vacHigh'};
    $ret{"sVacHigh"} = numtobool($vacH)
      if(defined($vacH));
    my $bin   = $staterep->{'binPause'};
    $ret{"sBinPause"} = numtobool($bin)
      if(defined($bin));
    my $carp  = $staterep->{'carpetBoost'};
    $ret{"sCarpetBoost"} = numtobool($carp)
      if(defined($carp));
    my $oo    = $staterep->{'openOnly'};
    $ret{"sOpenOnly"} = numtobool($oo)
      if(defined($oo));
    my $twop  = $staterep->{'twoPass'};
    $ret{"sTwoPass"} = numtobool($twop)
      if(defined($twop));
    my $naup  = $staterep->{'noAutoPasses'};
    $ret{"sNoAutoPasses"} = numtobool($naup)
      if(defined($naup));
    my $nopp  = $staterep->{'noPP'};
    $ret{"sNoPP"} = numtobool($nopp)
      if(defined($nopp));
    my $schH  = $staterep->{'schedHold'};
    $ret{"sSchedHold"} = numtobool($schH)
      if(defined($schH));
    my $cmd   = $staterep->{'lastCommand'}->{'command'};
    my $time  = $staterep->{'lastCommand'}->{'time'};
    my $init  = $staterep->{'lastCommand'}->{'initiator'};
    $ret{"lastCommand"} = $cmd
      if(defined($cmd));
    $ret{"lastCommandInitiator"} = $init
      if(defined($init));
    #-- extra function
    if( defined($key) && $key =~ /^local\:(.*)=(.*)/ ){
      #main::Log 1,"========> $1 = evaluation of $2 as ".eval($2);
      $ret{"$1"}=eval($2);
      $hash->{helper}{setting}="done";
    }
  }

  #-- getting events of the type
  # # {"state":{"reported":{"netinfo":{""bssid":"44:4e:6d:1f:24:20"}}}}
  my $bssid   = $staterep->{'netinfo'}->{'bssid'};
  $ret{"signalBssid"} = $bssid
    if(defined($bssid));
  
  #-- getting events of the type
  # {"state":{"reported":{"batPct":100}}}
  my $bat   = $staterep->{'batPct'};
  if(defined($bat)) {
    $ret{"battery"} = $bat;
  }
  
  #-- getting events of the type
  # {"state":{"reported":{"dock":{"known":false}}}}
  my $dock  = $staterep->{'dock'}->{'known'};
  $ret{"dockKnown"} = numtobool($dock)
    if(defined($dock));

  #-- getting events of the type
  # {"state":{"reported":{"audio":{"active":false}}}}
  my $audio = $staterep->{'audio'}->{'active'};
  $ret{"audioActive"} = numtobool($audio)
    if(defined($audio));

  #-- getting events of the type
  # {"state":{"reported":{"bin":{"present":true,"full":false}}}}
  my $binp  = $staterep->{'bin'}->{'present'};
  my $binf  = $staterep->{'bin'}->{'full'};
  $ret{"cmBinFull"} = numtobool($binf)
    if(defined($binf));

  if( $evt =~ /(wifiAnt)|(mssnNavStats)|(bbswitch)|(bbpause)|(connected)|(dock)|(country)|(cloudEnv)|(svcEndpoints)|(mapUpload)|(localtimeoffset)|(utctime)|(mac)|(wlcfg)|(wifistat)|(netinfo)|(langs)|(bbmssn)|(cap)|(navSwVer)|(tz)|(bbsys)|(bbchg)|(bbnav|bbswitch)|(bbpanic)/){
    #-- do nothing
    # {"state":{"reported":{"bbpause": {"pauses": [24, 24, 3, 18, 24, 46, 18, 43, 18, 24]}}}}
    # {"state":{"reported":{"langs":[{"en-UK":0},{"fr-FR":1},{"es-ES":2},{"it-IT":3},{"de-DE":4},{"ru-RU":5}],"bbnav":{"aMtrack":16,"nGoodLmrks":6,"aGain":4,"aExpo":102},"bbpanic":{"panics":[6,8,9,8,6]},"bbpause":{"pauses":[17,17,16,1,0,0,0,0,0,0]}}}}
    # {"state":{"reported":{"bbmssn":{"nMssn":30,"nMssnOk":2,"nMssnC":26,"nMssnF":2,"aMssnM":13,"aCycleM":13},"bbrstinfo":{"nNavRst":5,"nMobRst":0,"causes":"0000"}}}}
    # {"state":{"reported":{"cap":{"pose":1,"ota":2,"multiPass":2,"carpetBoost":1,"pp":1,"binFullDetect":1,"langOta":1,"maps":1,"edge":1,"eco":1,"svcConf":1},"hardwareRev":3,"sku":"R981040","batteryType":"lith","soundVer":"32","uiSwVer":"4582"}}}
    # {"state":{"reported":{"navSwVer":"01.12.01#1","wifiSwVer":"20992","mobilityVer":"5865","bootloaderVer":"4042","umiVer":"6","softwareVer":"v2.4.8-44"}}}
    # {"state":{"reported":{"tz":{"events":[{"dt":1583082000,"off":60},{"dt":1585443601,"off":120},{"dt":1603587601,"off":60}],"ver":8},"timezone":"Europe/Berlin","name":"Feger"}}}
    # {"state":{"reported":{"bbchg":{"nChgOk":8,"nLithF":0,"aborts":[0,0,0]},"bbswitch":{"nBumper":3350,"nClean":20,"nSpot":38,"nDock":35,"nDrops":80}}}}
    # {"state":{"reported":{"bbrun":{"hr":4,"min":58,"sqft":22,"nStuck":3,"nScrubs":5,"nPicks":74,"nPanics":16,"nCliffsF":166,"nCliffsR":102,"nMBStll":0,"nWStll":0,"nCBump":0},"bbsys":{"hr":207,"min":9}}}}
    # {"state":{"reported":{"bbnav":{"aMtrack":18,"nGoodLmrks":6,"aGain":5,"aExpo":102}}}}
    # {"state":{"reported":{"netinfo":{"dhcp":true,"addr":3232235568,"mask":4294967040,"gw":3232235774,"dns1":3232235774,"dns2":0,"bssid":"44:4e:6d:1f:24:20","sec":4}}}}
    # {"state":{"reported":{"wifistat":{"wifi":1,"uap":false,"cloud":1}}}}
    # {"state":{"reported":{"wlcfg":{"sec":7,"ssid":"48656E6E696E67486F6D654F6666696365"}}}}
    # {"state":{"reported":{"mac":"70:66:55:94:93:6f"}}}
    # {"state":{"reported":{"country": "DE"}}}
    # {"state":{"reported":{"cloudEnv": "prod"}}}
    # {"state":{"reported":{"svcEndpoints":{"svcDeplId": "v011"}}}}
    # {"state":{"reported":{"mapUploadAllowed":true}}}
    # {"state":{"reported":{"localtimeoffset":120,"utctime":1600424239,"pose":{"theta":-46,"point":{"x":318,"y":82}}}}}
    # {"state":{"reported":{"bbsys":{"hr":2583,"min":21}}}}
    # {"state":{"reported":{"wifiAnt":1}}}

  }elsif(int(%ret)==0){
  #  my ($evt) = @_;
    main::Log 1,"[RoombaUtils] uncaught event ".$evt
       if( $evt ne "$name" );
  }
  if( main::AttrVal($name,"debug","") eq "true" ){
    my $sub_ret = allevents($evt);
    @ret{ keys %{$sub_ret} } = values %{$sub_ret};
  }
  return {%ret}
}

#############################################################################
#
#  For debugging get all data
#
#############################################################################

sub allevents($){
  my ($evt) = @_;
  my %ans;
  #-- getting all events 
  my $dec = json2nameValue($evt);
  @ans{ keys %{$dec} } = values %{$dec};  
  return {%ans};
}

#############################################################################
#
#  signal data
#  getting events of the type
#  {"state":{"reported":{"signal":{"rssi":-55,"snr":34}}}}
#
#############################################################################

sub signale($){
  my ($evt) = @_;

  my $dec  = decode_json($evt);
  my $rssi = $dec->{'state'}->{'reported'}->{'signal'}->{'rssi'};
  my %ret  = ("signalRSSI",$rssi);
  return {%ret};
}

#############################################################################
#
#  position data
#  getting events of the type
#  {"state":{"reported":{"pose":{"theta":0,"point":{"x":311,"y":-21}}}}}
#
#############################################################################

sub pose($$){
  my ($name,$evt) = @_;
  
  my $hash = $main::defs{$name};
  my $dec   = decode_json($evt);
  my $pose  = $dec->{'state'}->{'reported'}->{'pose'};
  my $theta = $pose->{'theta'};
  my $px    = $pose->{'point'}->{'x'};
  my $py    = $pose->{'point'}->{'y'};

  #-- fast return if mapping disabled
  if( main::AttrVal($name,"noMap","") eq "true" ){
      my %ret   = ("positionTheta",$theta,"position","(".$px.",".$py.")");
      return {%ret};
  }
    
  my ($pxp,$pyp);
  
  initmap($hash)
    if( !defined($hash->{helper}{initmap}));
    
  if($hash->{helper}{initmap}==1){
    $hash->{helper}{startx} = $px;
    $hash->{helper}{starty} = $py;
    $hash->{helper}{initmap}=0;
    main::Log 1,"[RoombaUtils] initialX = $px, initialY = $py";
  }
  $px -= $hash->{helper}{startx};
  $py -= $hash->{helper}{starty};
  
  my $dir = main::AttrVal($name,"startdir","north");

  if($dir eq "north"){
    $pxp = -$py;
    $pyp =  $px;
  }elsif($dir eq "east"){
    $pxp = $px;
    $pyp = $py;
  }elsif($dir eq "south"){
    $pxp =  $py;
    $pyp = -$px;
  }elsif($dir eq "west"){
    $pxp = -$px;
    $pyp = -$py;
  }else{
    main::Log 1,"[RoombaUtils] invalid start direction $dir";
  }

  #-- Reduction not useful
  push(@{$hash->{helper}{theta}},$theta);
  push(@{$hash->{helper}{path}},$pxp,$pyp);
    
  my $count = $hash->{helper}{pcount};
  $count++;
  $hash->{helper}{pcount}=$count;
   
  my %ret   = ("positionTheta",$theta,"positionCount",$count,"position","(".$pxp.",".$pyp.")");
  return {%ret};
}

#############################################################################
#
#  schedule data
#
#############################################################################

sub schedule($$$){
  my ($name,$evtptr,$retptr) = @_;
  my @weekdays = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
  #my @weekdays = ("So","Mo","Di","Mi","Do","Fr","Sa");
  #-- getting events of the type
  # {"state":{"reported":{"cleanSchedule":{"cycle":["none","none","none","none","none","none","none"],"h":[9,9,9,9,9,9,9],"m":[0,0,0,0,0,0,0]},"bbchg3":{"avgMin":374,"hOnDock":199,"nAvail":32,"estCap":12311,"nLithChrg":8,"nNimhChrg":0,"nDocks":35}}}}
  my @acyc   = @{$evtptr->{'cycle'}};
  my @ahours = @{$evtptr->{'h'}};
  my @amin   = @{$evtptr->{'m'}};
  my $sched  = "[";
  for (my $i=0;$i<7;$i++){
    $sched .= $weekdays[$i].":".(($acyc[$i] eq "none")?"none":sprintf("%d:%02d",$ahours[$i],$amin[$i]));
    $sched .= ($i<6)?",":"]";
  }
  $retptr->{"progWeek"} = $sched;
  return
}

#############################################################################
#
#  schedule data type 2 for I7 
#
#############################################################################

sub schedule2($$$){
  #-- getting events of the type
  # {"state":{"reported":{"cleanSchedule2": [{"enabled": true, "type": 0,
  #  "start": {"day": [2, 4, 6], "hour": 11, "min": 0},
  #  "cmd": {"command": "start", "ordered": 1, "pmap_id": "z...g",
  #  "regions": [{"region_id": "10", "type": "rid"}, {"region_id": "6", "type": "rid"},
  #  {"region_id": "5", "type": "rid"}, {"region_id": "8", "type": "rid"}],
  #  "user_pmapv_id": "2...7"}}]}}}
  #my ($dec) = @_;
  my ($name,$evtptr,$retptr) = @_;
  my @weekdays = ("So","Mo","Di","Mi","Do","Fr","Sa");
  my @enabled;
  my @starthour;
  my @startmin;
  my @startday;
  my @userpmapvid;
  my @pmapid;
  my @region;
  my $nsched;
  my $nreg;
  my %answer = ();
  my $oldnreg;
  my $oldnsched = main::ReadingsVal($name,"NumOfSchedules","");
  for (my $i = 0; $i<14; $i++){
    # j is needed since @startday does somehow not work with $i...
    my $j = $i;
    $nsched = $i+1;
   
    $enabled[$i] = $evtptr->{'cleanSchedule2'}->[$i]->{'enabled'};
	
    # if schedules are no longer present in app or roomba, delete them in fhem, too
    if(!defined($enabled[$i])) {
      $retptr->{"NumOfSchedules"} = $i;
	    for (my $k = $i; $k < $oldnsched; $k++) {
		    main::Log 1,"[RoombaUtils] deleting old schedule ID $k, oldnsched No was $oldnsched";
		    my $hash = $main::defs{$name};
		    my $todel = $k+1;
		    main::readingsDelete($hash, "Schedule".$todel."Enabled");
		    main::readingsDelete($hash, "Schedule".$todel."Time");
		    main::readingsDelete($hash, "Schedule".$todel."UserPMapvID");
		    main::readingsDelete($hash, "Schedule".$todel."PMapID");
		    main::readingsDelete($hash, "Schedule".$todel."WeekDays");
      }
      last;
    }
	
    $retptr->{"Schedule".$nsched."Enabled"} = booltoyesno($enabled[$i]) if(defined($enabled[$i]));
	
    $starthour[$i] = $evtptr->{'cleanSchedule2'}->[$i]->{'start'}->{'hour'};
    $startmin[$i] = sprintf("%02d", $evtptr->{'cleanSchedule2'}->[$i]->{'start'}->{'min'});
    $retptr->{"Schedule".$nsched."Time"} = $starthour[$i].":".$startmin[$i] if(defined($starthour[$i]));
	
    $userpmapvid[$i] = $evtptr->{'cleanSchedule2'}->[$i]->{'cmd'}->{'user_pmapv_id'};
    $retptr->{"Schedule".$nsched."UserPMapvID"} = $userpmapvid[$i] if(defined($userpmapvid[$i]));
	
    $pmapid[$i] = $evtptr->{'cleanSchedule2'}->[$i]->{'cmd'}->{'pmap_id'};
    $retptr->{"Schedule".$nsched."PMapID"} = $pmapid[$i] if(defined($pmapid[$i]));
   
    @startday = @{$evtptr->{'cleanSchedule2'}->[$j]->{'start'}->{'day'}};
    for (@startday) {s/0/So/g;s/1/Mo/g;s/2/Di/g;s/3/Mi/g;s/4/Do/g;s/5/Fr/g;s/6/Sa/g;}
    $retptr->{"Schedule".$nsched."WeekDays"} = join(", ",@startday);
	
	$oldnreg = main::ReadingsVal($name,"Schedule".$nsched."NumOfRegions","1");
	for (my $m = 0; $m < 10; $m++) {
          $nreg = $m + 1;		
	  $region[$i][$m] = $evtptr->{'cleanSchedule2'}->[$i]->{'cmd'}->{'regions'}->[$m]->{'region_id'};
	  $retptr->{"Schedule".$nsched."Region".$nreg} = $region[$i][$m] if(defined($region[$i][$m]));

      if(!defined($region[$i][$m])) {
        $retptr->{"Schedule".$nsched."NumOfRegions"} = $m;
        for (my $k = $m; $k < $oldnreg; $k++) {
          main::Log 1,"[RoombaUtils] deleting old region ID $k, oldnreg No was $oldnreg";
          my $hash = $main::defs{$name};
          my $todel = $k+1;
          main::readingsDelete($hash, "Schedule".$nsched."Region".$todel);
        }
      last;
      }
	}
  }
  return
}

#############################################################################
#
#  mission data in bbrun
#
#############################################################################

#-- getting events of the type
# {"state":{"reported":{"bbrun"}}}
sub bbrun($$$) {
  my ($name,$evtptr,$retptr) = @_;
  my $hash = $main::defs{$name};

  my $runh = $evtptr->{'hr'};
  my $runm = $evtptr->{'min'};
  my $evacs = $evtptr->{'nEvacs'};
  $retptr->{"bbrEvacs"} = $evacs;
  $retptr->{"bbrTime"} = $runh.":".$runm;
  $retptr->{"bbrTime2"} = int($runh / 24)."d ".($runh % 24)."h ".$runm."m";
 
  #--
  if(defined($evtptr->{'sqft'})) {
    my $sqm   = int($evtptr->{'sqft'}*10/10.7639)/10;
    $retptr->{"bbrArea"} = $sqm." m²";
  }
}
  
#############################################################################
#
#  mission data
#
#############################################################################

#-- getting events of the type
# {"state":{"reported":{"dock":{"known":true},"cleanMissionStatus":{"cycle":"quick","phase":"run","expireM":0,"rechrgM":0,"error":0,"notReady":0,"mssnM":0,"sqft":0,"initiator":"localApp","nmain::Log 1,"[RoombaUtils] Device $name phase transition $oldphase -> $phase";Mssn":30}}}}
sub mission($$$){
  my ($name,$evtptr,$retptr) = @_;
  my $hash = $main::defs{$name};
  my $oldphase = main::ReadingsVal($name,"cmPhase","");
  my $bat = main::ReadingsVal($name,"battery","");
  $retptr->{"cmCycle"} = $evtptr->{'cycle'};
  my $phase = $evtptr->{'phase'}; 
  $retptr->{"cmPhase"} = $phase;
  $retptr->{"cmPhaseE"} = $roombastates_en{$phase};
  $retptr->{"cmPhaseD"} = $roombastates_de{$phase};
  
  #-- sqft is outside cleanMissionStatus in some newer firmware versions ???
  if(defined($evtptr->{'sqft'})) {
    my $sqm   = $evtptr->{'sqft'};
    #main::Log 1,"$name has sqft found in cleanMissionStatus as $sqm";
  }
  
  #-- sqft is outside cleanMissionStatus in some newer firmware versions ???
  if(defined($evtptr->{'mssnM'})) {
    my $sqm   = $evtptr->{'mssnM'};
    #main::Log 1,"$name has mssnM found in cleanMissionStatus as $sqm";
  }
  
  my $number= $evtptr->{'nMssn'};
  my $rech  = $evtptr->{'rechrgM'};
 
  my $exp   = $evtptr->{'expireM'};
  $exp = ($exp == 0)?"Never":$exp." min";
  $retptr->{"cmExpire"} =  $exp;
  
  $retptr->{"cmTime"} = ($evtptr->{'mssnM'})." min";
  
  my $error = $evtptr->{'error'};
  my $eemsg = $roombaerrs_en{$error};
  my $demsg = $roombaerrs_de{$error};
  $retptr->{"cmError"}  = $eemsg;
  $retptr->{"cmErrorD"} = $demsg;
  if( $oldphase ne "stuck" && $phase eq "stuck"){
    main::Log 1,"[RoombaUtils] $name stuck with error $error, message $eemsg";
  }
  
  my $notr  = $evtptr->{'notReady'};
  $retptr->{"cmNotReady"} = numtobool($notr)
    if(defined($notr));
    
  #-- sqft is outside cleanMissionStatus in some newer firmware versions ???
  #if(defined($evtptr->{'sqft'})) {
  #  my $sqm   = int($evtptr->{'sqft'}*10/10.7639)/10;
  #  $retptr->{"cmArea"}      = $sqm." m²";
  #}
  
  $retptr->{"cmInitiator"} = $evtptr->{'initiator'};
  
  #-- Manage mission
  missionmanager($hash,$oldphase,$phase);  
  
  return
  }
 
#############################################################################
#
#  mission management
#
#############################################################################

sub missionmanager($$$){
  my ($hash,$oldphase,$phase)=@_;
  
  my $name     = $hash->{NAME};
  my $iodev    = $hash->{IODev}->{NAME};
  
  #  Normal Sequence is "" -> charge -> run -> hmPostMsn -> charge
  #  hapege fir I7: charge -> run -> hmPostMsn -> evac -> hmPostMsn -> run -> charge -> hmPostMsn -> run -> charge
  #        Mid mission recharge is "" -> charge -> run -> hmMidMsn -> charge
  #                                   -> run -> hmPostMsn -> charge
  #        Stuck is "" -> charge -> run -> hmPostMsn -> stuck
  #                    -> run/charge/stop/hmUsrDock -> charge
  #        Start program during run is "" -> run -> hmPostMsn -> charge
  #        Need to identify a new mission to initialize map, and end of mission to
  #        finalise map.
  #        Assume  charge -> run = start of mission (init map)
  #                stuck -> charge = init map ???
  #        Assume hmPostMsn -> charge = end of mission (finalize map)
  #               hmPostMsn -> charge = end of mission (finalize map)
  #               hmUsrDock -> charge finalize map
  #               hmUsrDock -> stop finalize map
  #        Anything else = continue with existing map
  
  if( $oldphase.$phase eq "stuckcharge" ||
      $oldphase.$phase eq "chargerun" ||
      $oldphase.$phase eq "hmUsrDockrun" ){
    main::Log 1,"[RoombaUtils] Device $name $oldphase -> $phase should start intialization";
    initmap($hash)
      if( main::AttrVal($name,"noMap","") ne "true" );
  }elsif( $oldphase.$phase eq "runstop" ){
    main::Log 1,"[RoombaUtils] Device $name pausing $oldphase -> $phase";
  }elsif( $oldphase.$phase eq "stoprun" ){
    main::Log 1,"[RoombaUtils] Device $name resuming $oldphase -> $phase";
  }elsif( 
          $oldphase.$phase eq "hmPostMsncharge" ||
          $oldphase.$phase eq "hmPostMsnstop" ||
          $oldphase.$phase eq "hmUsrDockcharge" ||
          $oldphase.$phase eq "hmUsrDockstop" ||
          $oldphase.$phase eq "runcharge" ||
		  $oldphase.$phase eq "stopcharge"){
    main::Log 1,"[RoombaUtils] Device $name $oldphase -> $phase should start finalization";
    finalizemap($hash)
      if( main::AttrVal($name,"noMap","") ne "true" );
  }elsif( 
          $oldphase.$phase eq "hmUsrDockhmUsrDock"){
    main::Log 1,"[RoombaUtils] Device $name sent to dock";
  }elsif(
          $oldphase.$phase eq "hmUsrDockhmUsrDock"){
    main::Log 1,"[RoombaUtils] Device $name arrived in dock after user docking";
             # $oldphase.$phase eq "stophmUsrDock"  ||
  }elsif( $oldphase.$phase eq "runrun" ||
          $oldphase.$phase eq "stopstop" ||
          $oldphase.$phase eq "chargestop" ||
          $oldphase.$phase eq "chargecharge" ||
          $oldphase.$phase eq "hmUsrDockhmUsrDock"){
    # do nothing
  }else{
    main::Log 1,"[RoombaUtils] Device $name phase transition $oldphase -> $phase";
  }
  
}
 
#############################################################################
#
#  initmap
#
#############################################################################

sub initmap($){
  my ($hash) = @_;
  $hash->{helper}{initmap}=1;
  $hash->{helper}{path}=();
  $hash->{helper}{pcount}=0;
  $hash->{helper}{theta}=();
  $hash->{helper}{thetaold}=undef;
  # hapege
  my $name = $hash->{NAME};
  my $oldmap = main::ReadingsVal($name,"cmMap","none");
  $hash->{helper}{oldmap} = $oldmap;
  # /hapege
  main::Log 1,"[RoombaUtils] Initialization of map for device ".$hash->{NAME};
  main::fhem("setreading ".($hash->{NAME})." cmMap initialized");
  }
  
#############################################################################
#
#  listmaps
#
#############################################################################

sub listmaps($){
  my ($name) = @_;
  
  my $hash = $main::defs{$name};
  my $out    = "<html>";
  #my $now    = main::TimeNow();
  my $run    = 0;
  
  #main::Log 1,"[RoombaUtils] mapping for device $name";
  
  my ($fhb,$fhc);
  my $svgdir =  main::AttrVal($name,"SVG_dir","/opt/fhem/www/images");
           
  #-- reading and modyfying collection filename
  my $filename2b = main::AttrVal($name,"SVG_collect",undef);
  if(!$filename2b){
    $filename2b = sprintf("SVG_%s.xml",$name);
    main::Log 1,"[RoombaUtils] No filename attribute SVG_collect given, using default $filename2b";
  }
  if(!open($fhb, "<".$svgdir."/".$filename2b)){
    main::Log 1,"[RoombaUtils] collection file $filename2b cannot be opened for reading, assuming empty file";
  }else{
    while (my $line = <$fhb> ) {
      if( $line =~ /^<.*Roomba.*run on ([\d\-]*) ([\d:]*)/){
        $run++;
        $out .= "<button type=\"button\" onclick=\"{var mw=window.open(location.href+'&XHR=1&cmd.global=set%20$name%20mapdel%20$run','','width=10,height=10');;setTimeout(function(){mw.close()},3000)}\">Löschen</button> $run: mission $1 $2";
      }
      if( $line =~ /^.*Path containing (\d*)/){
        $out .= " with $1 points<br/>";
      }
    }
    close($fhb);  
    $out.="</html>";
  }
  #main::Log 1,"[RoombaUtils] setting READING cmMapList for device $name at time $now";
  #$hash->{READINGS}{cmMapList}{VAL}=$out;
  #$hash->{READINGS}{cmMapList}{TIME}=$now;
  main::fhem("setreading $name cmMapList $out");
  return
}

#############################################################################
#
#  delmap
#
#############################################################################

sub delmap($$){
  my ($name,$evt) = @_;
  return 
    if($evt !~ /mapdel\s*(\d*)/);
  my $rundel = $1;
  
  my $hash = $main::defs{$name};
  my $out    = "<html>";
  #my $now    = main::TimeNow();
  my $run    = 0;
  
  #main::Log 1,"[RoombaUtils] deleting run $rundel for device $name";
  
  my ($fhb,$fhc);
  my $svgdir =  main::AttrVal($name,"SVG_dir","/opt/fhem/www/images");
           
  #-- reading and modyfying collection filename
  my $filename2b = main::AttrVal($name,"SVG_collect",undef);
  if(!$filename2b){
    $filename2b = sprintf("SVG_%s.xml",$name);
    main::Log 1,"[RoombaUtils] No filename attribute SVG_collect given, using default $filename2b";
  }
  if(!open($fhb, "<".$svgdir."/".$filename2b)){
    main::Log 1,"[RoombaUtils] collection file $filename2b cannot be opened for reading";
    return
  }else{
    #-- opening temporary collection filename
    if(!open($fhc, ">".$svgdir."/".$filename2b.".tmp")){
      main::Log 1,"[RoombaUtils] temporary collection file $filename2b.tmp cannot be opened for writing, ERROR";
      return
    }
    while (my $line = <$fhb> ) {
      if( $line =~ /^<.*Roomba.*run on ([\d\-]*) ([\d:]*)/){
        $run++;
        if( $run < $rundel ){
          $out .= "<button type=\"button\" onclick=\"{var mw=window.open(location.href+'&XHR=1&cmd.global=set%20$name%20mapdel%20$run','','width=10,height=10');;setTimeout(function(){mw.close()},3000)}\">Löschen</button> $run: mission $1 $2";
          #main::Log 1,"=====> run = $run because rundel=$rundel";
        }elsif( $run > $rundel ){
          my $runtemp = $run-1;
          $out .= "<button type=\"button\" onclick=\"{var mw=window.open(location.href+'&XHR=1&cmd.global=set%20$name%20mapdel%20$runtemp','','width=10,height=10');;setTimeout(function(){mw.close()},3000)}\">Löschen</button> $runtemp: mission $1 $2";
          #main::Log 1,"=====> run = $run, but displaying as ".($run-1)." because rundel=$rundel";
        }else{
          #main::Log 1,"=====> run = $run, but not writing this out";
        }
      }elsif( $line =~ /^.*Path containing (\d*)/){
        $out .= " with $1 points<br/>"
          if( $run != $rundel );
      }
      print $fhc $line
        if( $run != $rundel ); 
    }
    close($fhc);
    close($fhb);  
        $out.="</html>";
    rename $svgdir."/".$filename2b.".tmp",$svgdir."/".$filename2b;
  }

  main::fhem("setreading $name cmMapList $out");
  return
}

#############################################################################
#
#  finalizemap
#
#############################################################################

sub finalizemap($){
  my ($hash) = @_;
  
  my $name   = $hash->{NAME};
  if(!defined($hash->{helper}{path})){
     main::Log 1,"[RoombaUtils] Finalization of map for device $name not possible, path undefined";
     # hapege
     my $oldmap = "none";
     $oldmap =$hash->{helper}{oldmap} if (defined($hash->{helper}{oldmap}));
     main::fhem("setreading $name cmMap $oldmap");
     #/hapege
     return
  }
  my @points = @{$hash->{helper}{path}};
  my @theta  = @{$hash->{helper}{theta}};
  my $out1   = "";
  my $out2   = "";
  my $out3   = "";
  
  if(int(@points) < 1){
    main::Log 1,"[RoombaUtils] Finalization of map for device $name not possible, empty path";
    # hapege
    my $oldmap = "none";
    $oldmap =$hash->{helper}{oldmap} if (defined($hash->{helper}{oldmap}));
    main::fhem("setreading $name cmMap $oldmap");
    #/hapege
    return
  }
  main::Log 1,"[RoombaUtils] Finalization of map for device ".$name;
  main::fhem("setreading ".($hash->{NAME})." cmMap finalizing");
  
  #-- The robot needs a moment to orient itself. First points are invalid therefore.
  #   Max. 10 points before robot takes off in direction 0
  my $numcoords = int(@points)/2;
  my $numoffset=0;
  my ($px,$py);
  for(my $i=1;$i<10;$i++){
    last 
      if(!defined($points[2*$i]));
    $px=$points[2*$i];
    $py=$points[2*$i+1];
    if( $px==0 && $py==0) {
       $numoffset=$i;
       last;
    }
  }
  # hapege
  main::Log 1,"[RoombaUtils] finalizemap numoffset: $numoffset, px: $px, py: $py";
  # /hapege
  splice @points, 0, 2*$numoffset;
  splice @theta,  0, $numoffset;
  $numcoords -= $numoffset;
  
  #-- calculate velocities
  my $pxold=0;
  my $pyold=0;
  my @velocity=();
  for(my $i=1; $i<$numcoords; $i++){ 
     $px=$points[2*$i];
     $py=$points[2*$i+1];
     my $v=int(sqrt( ($px-$pxold)**2 + ($py-$pyold)**2 )*10)/10;
     push @velocity, $v;
     $pxold = $px;
     $pyold = $py;
  }  
  
  #-- the following procedures are destructive for the points array
  #   thus create a copy
  my @points2 = @points;
 
  #-- move points into array of arrays for bounding box
  my @newpoints = ();
  push @newpoints, [ splice @points2, 0, 2 ] while @points2;
  my ($xmin, $ymin, $xmax, $ymax) = polygon_bbox(@newpoints);
  my @bbox = ($xmin, $ymin, $xmax, $ymax);

  my @newhull=();
  my @newhull2=();
  my @centroid=();
    
  #-- convex hull Math::ConvexHull
  eval(@newhull = @{convex_hull(\@newpoints)}) ;
  if(@newhull){
    #-- Close the polygon
    my @first = ();
    push(@first,$newhull[0][0],$newhull[0][1]);
    push(@newhull, \@first);

    my $numcoords2 = int(@newhull);
  
    for (my $i=0;$i<$numcoords2;$i++){
      push(@newhull2,$newhull[$i][0],$newhull[$i][1])
    }
  
    #-- centroid of convex hull Math::Polygon::Calc
    eval(@centroid = @{polygon_centroid(@newhull)});
  }
  
  #######################################################
  #-- prepare content and filename for file 1 only if LOG_dir is set
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  if(main::AttrVal($name,"LOG_dir",undef)){
    my $filename1 = sprintf("%s/%s_%04d-%02d-%02d_%02d%02d.pl",main::AttrVal($name,"LOG_dir",undef),$name,$year+1900,$mon+1,$mday,$hour,$min);
    $out1 .= sprintf("# Roomba %s run on %04d-%02d-%02d %02d:%02d\n",$name,$year+1900,$mon+1,$mday,$hour,$min);
    $out1 .= "# Path containing ".$numcoords." points\n";
    $out1 .= "# Removed first $numoffset points\n"
      if($numoffset > 0);
    $out1 .= "# WARNING: angle not zero at offset position, but ".$theta[0]."\n"
      if( $theta[0] != 0);
  
    #-- area from robot
    $out1 .= "my \$cmarea=".main::ReadingsNum($name,"cmArea",0).";\n";
  
    #-- minx,miny, maxx, maxy
    $out1 .= "my \@bbox=(".join(',',@bbox).");\n";
  
    #-- convex hull
    $out1 .= "my \@conhull=(".join(',',@newhull2).");\n";
    $out1 .= sprintf("my \@cenhull=(%.2f,%.2f);\n",$centroid[0],$centroid[1]);
  
    #-- longer data
    $out1  .= "my \@points=(".join(',',@points).");\n".
            "my \@theta=(".join(',',@theta).");\n".
            "my \@velocity=(".join(',',@velocity).");\n";
            
    if(open(FH, ">".$filename1)) {
      binmode (FH);
      print FH $out1;
      close(FH);
    }else {
      main::Log 1, "[RoombaUtils] Can't open $filename1: $!";
    }
  }
  
  #-- save a lot of memory
  $hash->{helper}{path}=();
  $hash->{helper}{theta}=();
  
  #######################################################              
  #-- prepare content and filename for file 2
  #-- room filename
  my ($fha,$fhb,$fhc);
  my $filename2a = main::AttrVal($name,"SVG_room",undef);
  if(!$filename2a){
    main::Log 1,"[RoombaUtils] No filename attribute SVG_room given, no map drawn";
    return;
  }
  my $svgdir =  main::AttrVal($name,"SVG_dir","/opt/fhem/www/images");
  if(!open( $fha, "<".$svgdir."/".$filename2a)){
    main::Log 1,"[RoombaUtils] SVG file $filename2a cannot be opened for reading, no map drawn";
    return;
  }
  
  #-- output filename
  my $filename2c = main::AttrVal($name,"SVG_final",undef);
  if(!$filename2c){
    main::Log 1,"[RoombaUtils] No filename attribute SVG_final given, no map drawn";
    close($fha);
    return;
  }
  if(!open($fhc, ">".$svgdir."/".$filename2c)){
    main::Log 1,"[RoombaUtils] SVG file $filename2c cannot be opened for writing, no map drawn";
    close($fha);
    return;
  }
  
  #-- copy room file to output file without </svg> tag
  while (my $line = <$fha> ) {
    print $fhc $line
      if( $line !~ /.*\<\/svg\>.*/);
  }
  close($fha);
  
  #-- get colors
  my @coldark  = ("green","orange","red","blue");
  my @colbrite = ("lightreen","yellow","pink","lightblue");
  for( my $i=0; $i<4; $i++){
    my ($cold,$colb) = split(':',main::AttrVal($name,"SVG_color".($i+1),undef));
    $coldark[$i]=$cold
      if( $cold);
    $colbrite[$i]=$colb
      if( $colb);
  }
          
  #-- reading and modyfying collection filename
  my $filename2b = main::AttrVal($name,"SVG_collect",undef);
  my $collno     = 0;
  my $collid     = "";
  my $collstr    = "";
  if(!$filename2b){
    $filename2b = sprintf("SVG_%s.xml",$name);
    main::Log 1,"[RoombaUtils] No filename attribute SVG_collect given, using default $filename2b";
  }
  if(!open($fhb, "<".$svgdir."/".$filename2b)){
    main::Log 1,"[RoombaUtils] collection file $filename2b cannot be opened for reading, assuming empty file";
  }else{
    while (my $line = <$fhb> ) {
      for( my $i=0; $i<4; $i++){ 
        $line =~ s/$coldark[$i]/$colbrite[$i]/g;
      }
      if( $line =~ /\<g id="(.*)\|(.*)" transform.*/){
        $collno++;
        $collid  = $1;
        $collstr = $2;
        #-- insert additional interaction line
        print $fhc  "<text x=\"30\" y=\"".(15*$collno+35)."\" fill=\"red\" font-weight=\"bold\" onmouseover=\"document.getElementById('".$collid."').setAttribute('fill', 'blue')\"".
                    " onmouseout=\"document.getElementById('".$collid."').setAttribute('fill', 'none')\">".$collstr."</text>\n";
      }
      $out3 .= $line;
    }
    close($fhb);  
  }
  #-- reopening collection filename
  if(!open($fhb, ">>".$svgdir."/".$filename2b)){
    main::Log 1,"[RoombaUtils] collection file $filename2b cannot be opened for writing, ERROR";
  }
   
  #-- create output
  $collstr = sprintf("%04d-%02d-%02d %02d:%02d",$year+1900,$mon+1,$mday,$hour,$min);
  $collid  = "g".md5_hex($collstr);
  $out2 .= "<!-- # Roomba $name run on $collstr\n";
  $out2 .= "     # Path containing ".$numcoords." points\n";
  $out2 .= "     # Removed first $numoffset points\n"
    if($numoffset > 0);
  $out2 .= "     # WARNING: angle not zero at offset position, but ".$theta[0]."\n"
    if( $theta[0] != 0);
  $out2 .= "-->\n";
  
  #-- reading start position in order to do translation
  my $startx = main::AttrVal($name,"startx",0);
  my $starty = main::AttrVal($name,"starty",0);
  $out2 .= "<g id=\"".$collid."|".$collstr."\" transform=\"translate(".$startx." ".$starty.") scale(1 -1)\">\n";

  #-- area from robot
  $out2 .= "<!-- area ".main::ReadingsNum($name,"cmArea",0)." -->\n";
  
  #-- minx,miny, maxx, maxy
  $out2 .= "<!-- bbox ".join(',',@bbox)." -->\n";
  
  #-- convex hull
  $out2 .= "<!-- convex hull -->\n".
           "<polyline stroke=\"".$coldark[0]."\" fill=\"none\"\n".
           "          points=\"".join(',',@newhull2)."\"/>\n".
           "<!-- center convex hull -->\n".
           "<circle r=\"10\" cx=\"".$centroid[0]."\" cy=\"".$centroid[1]."\" fill=\"".$coldark[1]."\"/>\n";
  
  $out2 .= "<!-- startpoint -->\n<circle r=\"10\" cx=\"0\" cy=\"0\" fill=\"".$coldark[2]."\"/>\n";

  #-- longer data
  $out2  .= "<!-- points -->\n".
            "<polyline id=\"".$collid."\" stroke=\"".$coldark[3]."\" fill=\"none\"\n".
            "          points=\"".join(',',@points)."\"/>\n";
            
  $out2 .= "</g>\n";
  
  #-- write output to svg file with additional interaction line
  print $fhc  "<text x=\"30\" y=\"".(15*$collno+50)."\" fill=\"red\" font-weight=\"bold\" onmouseover=\"document.getElementById('".$collid."').setAttribute('fill', 'blue')\"".
                    " onmouseout=\"document.getElementById('".$collid."').setAttribute('fill', 'none')\">".$collstr."</text>\n";
  print $fhc $out3;
  print $fhc $out2;
  print $fhc "</svg>\n";
  close($fhc);
  
  #-- write output to collection file
  print $fhb $out2;
  close($fhb);
  main::fhem("setreading $name cmMap <html>finalized as <a href=\"/fhem/images/".$filename2c."\">".$filename2c."</a></html>");
  listmaps($name)
}

#######################################################################################
#
# makeShort 
#   
# FW_summaryFn handler for creating the html output in FHEMWEB
#
#######################################################################################

sub makeShort($$$$){
    my ($FW_wname, $devname, $room, $extPage) = @_;
    my $hash = $main::defs{$devname};
    main::Log 1,"==============> roomba:makeShort";
    
    my $name = $hash->{NAME};
    #my $wwwpath = $hash->{HELPER}->{wwwpath};
    my $alias = main::AttrVal($hash->{NAME}, "alias", $hash->{NAME});
    my ($state,$timestamp,$number,$result,$duration,$snapshot,$record,$nrecord);
    
    # my $cnt = int(@{$hash->{DATA}});
    my $ret = "</td><td><div class=\"col2\">"."Hello World from makeShort"."</div>";
    
    return ($ret);
}

#######################################################################################
#
# makeTable 
#  
# FW_detailFn handler for creating the html output in FHEMWEB
#
#######################################################################################

sub makeTable($$$$){
    my ($FW_wname, $devname, $room, $extPage) = @_;
    my $hash = $main::defs{$devname};
    main::Log 1,"==============> roomba:makeTable";
    # my $cnt = int(@{$hash->{DATA}});
    my $ret = "<div class=\"col2\"><img src=\"http://192.168.0.94:8083/fhem/images/SVG_RoombaSauger.svg\" width=\"600\"></div>";

}

1;


=pod
=item helper
=item summary Control of Roomba cleaning robots
=item summary_DE Steuerung von Roomba Reinigungsrobotern
=begin html

<a name="RoombaUtils"></a>
<h3>RoombaUtils</h3>
<ul>RoombaUtils<br><br> 
	<b>Note:</b> The following libraries  are required for this module:
	<ul>
		<li></li><br>
	  Use <b>sudo apt-get install </b> to install this libraries.<br>
	  Use <b>sudo apt-get install cpanminus</b> and <b>sudo cpanm XXX</b> to update to the newest version.<br><br>
	</ul><br><br>
	
<a name="Roombadefine" id="Roombadefine"></a>
  <b>Define</b>
  <ul>
  	<code>define &lt;name&gt; </code><br><br>
  </ul><br>

<a name="Roombaset" id="Roombaset"></a>
<b>Set</b>
		<ul><code>set &lt;name&gt; &lt;command&gt; [&lt;parameter&gt;]</code><br><br>
             The following commands are defined for the robots :<br><br>
      <ul>
        <li><code><b>start</b></code> &nbsp;&nbsp;-&nbsp;&nbsp; start cleaning mission</li>
        <li><code><b>pause</b></code> &nbsp;&nbsp;-&nbsp;&nbsp; pause the robot</li>
        <li><code><b>resume</b></code> &nbsp;&nbsp;-&nbsp;&nbsp; resume the cleaning mission</li>
        <li><code><b>dock</b></code> &nbsp;&nbsp;-&nbsp;&nbsp; end the cleaning mission and dock the robot</li>
        <li><code><b>stop</b></code> &nbsp;&nbsp;-&nbsp;&nbsp; end the cleaning mission and leave the robot where it is</li>
         </ul><br>
</ul>
 <a name="Roombaget" id="Roombaget"></a>
 <b>Get</b>
  <ul>
    <code>n/a</code>
  </ul><br>

 <a name="Roombaattr" id="Roombaattr"></a>
 <b>Attributes</b>
  <ul>
  	<ul>
      <li><code><b>startx</b> <number></code>&nbsp;&nbsp;-&nbsp;&nbsp; docking station x coordinate in cm from the leftmost (western) wall</li>
      <li><code><b>starty</b> <number></code>&nbsp;&nbsp;-&nbsp;&nbsp; docking station y coordinate in cm from the bottommost (southern) wall</li>
      <li><code><b>startdir</b> east|south|west|north </code>&nbsp;&nbsp;-&nbsp;&nbsp; starting direction away from docking station</li>
      <li><code><b>noMap</b> true|false</code>&nbsp;&nbsp;-&nbsp;&nbsp; if set to true, no map data will be collected</li>
      <li><code><b>LOG_dir</b> <directory name> </code>&nbsp;&nbsp;-&nbsp;&nbsp; directory for writing a log file (in perl format!) of each cleaning mission.
         If this attribute is omitted, no such file will be written</li>
      <li><code><b>SVG_dir</b> <directory name> </code>&nbsp;&nbsp;-&nbsp;&nbsp; directory for reading a graphical room map in SVG format and reading/writing intermediate XML files of each cleaning mission.
         If this attribute is omitted, the default <code>/opt/fhem/www/images</code> will be used</li>. Note: In order to display the files via FHEMWEB frontend, they must reside in the working space of the web server.
      <li><code><b>SVG_room</b> <file name> </code>&nbsp;&nbsp;-&nbsp;&nbsp; filename for reading a graphical room map in SVG format.
         If this attribute is missing, no such file will be written</li>
      <li><code><b>SVG_collect</b> <file name> </code>&nbsp;&nbsp;-&nbsp;&nbsp; filename for reading/writing intermediate XML file of each cleaning mission.
         If this attribute is missing, the default <code>SVG_<device>.xml</code> will be used</li>
      <li><code><b>SVG_final</b> <file name> </code>&nbsp;&nbsp;-&nbsp;&nbsp; filename for writing final SVG file of each cleaning mission.
         If this attribute is missing, the default <code>SVG_<device>.svg</code> will be used</li>
      <li><code><b>SVG_color1</b> <dark color>:<light color> </code>&nbsp;&nbsp;-&nbsp;&nbsp; two colors separated by :. The first color will be used for drawing the convex hull of the robot path, 
         the second color will be used for replacement of this color in old maps. Default: <code>green:lightgreen</code>.</li>
      <li><code><b>SVG_color2</b> <dark color>:<light color> </code>&nbsp;&nbsp;-&nbsp;&nbsp; two colors separated by :. The first color will be used for drawing the center of the convex hull of the robot path, 
         the second color will be used for replacement of this color in old maps. Default: <code>green:lightgreen</code>.</li>
      <li><code><b>SVG_color3</b> <dark color>:<light color> </code>&nbsp;&nbsp;-&nbsp;&nbsp; two colors separated by :. The first color will be used for drawing the starting point of the robot path, 
         the second color will be used for replacement of this color in old maps. Default: <code>green:lightgreen</code>.</li>
      <li><code><b>SVG_color4</b> <dark color>:<light color> </code>&nbsp;&nbsp;-&nbsp;&nbsp; two colors separated by :. The first color will be used for drawing the robot path, 
         the second color will be used for replacement of this color in old maps. Default: <code>green:lightgreen</code>.</li>
        
   </ul><br>
</ul>
=end html

=begin html_DE

<a name="RoombaUtils"></a>
<h3>RoombaUtils</h3>
=end html_DE
=cut