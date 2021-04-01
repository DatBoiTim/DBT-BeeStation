/******************************************************
* ----------------------BSNet--------------------------
* Initially Designed by: DatBoiTim and Francinum
* Original Repository: Beestation/Beestation-Hornet
* Project Started: 2/28/2021
* BSNet: Designed to replace TComms and NTNet
******************************************************/

/*
* Datagram Datums
* Contains:
* packet
* helperprocs
*/

/datum/packet //Basically IPv4 Datagram just really stripped down to the essentials
	var/srcAddress //Source Address
	var/dstAddress //Destination
	var/list/data = list()

//Standard Args Constructor
/datum/packet/New(argSRCAddress, argDSTAddress, argFlag, argProtocol, argType, argData)
	srcAddress = argSRCAddress
	dstAddress = argDSTAddress
	//Associative fields for data
	data["flags"] = argFlag
	data["protocol"] = argProtocol
	data["type"] = argType
	data["data"] = argData

//Copy Constructor
/datum/packet/New(datum/packet/P)
	srcAddress = P.srcAddress
	dstAddress = P.dstAddress
	data["flags"] = P.data["flags"]
	data["protocol"] = P.data["protocol"]
	data["type"] = P.data["type"]
	data["data"] = P.data["data"]
/*
* Interface Datums
* Contains:
* interface
* wiredInterface
* Powernet connection procs
* wirelessInterface
* helperprocs
*/

/datum/component/interface //Parent Class for Interfaces
	var/obj/connectedDevice //The Device which the interface is attached to
	var/address //Maximum address size is 65535. Any positive integer between 0 and this is valid. Addresses are actually technically assigned to the interface and not the device, hence it is here.

//Standard Args Constructor
/datum/component/interface/New(obj/D, addy)
	connectedDevice = D
	address = addy

/datum/component/interface/wired
	var/datum/powernet/powernet //Powernet Connected. We all love PoE, it's time for EoP

//Standard Args Constructor
/datum/component/interface/wired/New(datum/powernet/P, obj/D, addy)
	powernet = P
	..(D, addy)

//Connects Connected Device to the Powernet
/datum/component/interface/wired/proc/connect_to_network()
	var/turf/T = connectedDevice.loc
	if(!T || !istype(T))
		return FALSE

	var/obj/structure/cable/C = T.get_cable_node()
	if(!C || !C.powernet)
		return FALSE

	C.powernet.add_machine(src)
	return TRUE

/datum/component/interface/wired/proc/disconnect_from_network()
	if(!powernet)
		return 0 //No Powernet Connected
	powernet.remove_interface(src)
	return 1 //Powernet Successfully Disconnected

/datum/component/interface/wireless
	var/datum/radio_frequency/radio_connection

//Standard Args Constructor
/datum/component/interface/wireless/New(datum/radio_frequency/R, obj/D, addy)
	radio_connection = R
	SSradio.add_object(src, radio_connection)
	..(D, addy)

/datum/component/interface/wireless/change_freq(/datum/radio_frequency/N)
	SSradio.remove_object(src, radio_connection)
	radio_connection = N
	SSradio.add_object(src, radio_connection)
