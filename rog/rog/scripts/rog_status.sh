#!/bin/sh

#alias echo_date='echo $(date +%Y年%m月%d日\ %X)'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
model=$(nvram get productid)
#=================================================

# CPU温度
cpu_temperature="CPU：$(cat /proc/dmu/temperature | awk '{print $4}' | grep -Eo '[0-9]+')°C"

case "$model" in
RT-AC5300|RT-AC88U|RT-AC3100)
	WLEXE=wl1
	;;
*)
	WLEXE=wl
	;;
esac

#网卡温度
case "$model" in
RT-AC5300)
	interface_2g=$(nvram get wl0_ifname)
	interface_5g1=$(nvram get wl1_ifname)
	interface_5g2=$(nvram get wl2_ifname)
	interface_2g_temperature=$($WLEXE -i ${interface_2g} phy_tempsense | awk '{print $1}') 2>/dev/null
	interface_5g1_temperature=$($WLEXE -i ${interface_5g1} phy_tempsense | awk '{print $1}') 2>/dev/null
	interface_5g2_temperature=$($WLEXE -i ${interface_5g2} phy_tempsense | awk '{print $1}') 2>/dev/null
	interface_2g_power=$($WLEXE -i ${interface_2g} txpwr_target_max | awk '{print $NF}') 2>/dev/null
	interface_5g1_power=$($WLEXE -i ${interface_5g1} txpwr_target_max | awk '{print $NF}') 2>/dev/null
	interface_5g2_power=$($WLEXE -i ${interface_5g2} txpwr_target_max | awk '{print $NF}') 2>/dev/null
	[ -n "${interface_2g_temperature}" ] && interface_2g_temperature_c="$(expr ${interface_2g_temperature} / 2 + 20)°C" || interface_2g_temperature_c="offline"
	[ -n "${interface_5g1_temperature}" ] && interface_5g1_temperature_c="$(expr ${interface_5g1_temperature} / 2 + 20)°C" || interface_5g1_temperature_c="offline"
	[ -n "${interface_5g2_temperature}" ] && interface_5g2_temperature_c="$(expr ${interface_5g2_temperature} / 2 + 20)°C" || interface_5g2_temperature_c="offline"
	wl_temperature="2.4G：${interface_2g_temperature_c} &nbsp;&nbsp;|&nbsp;&nbsp; 5G-1：${interface_5g1_temperature_c} &nbsp;&nbsp;|&nbsp;&nbsp; 5G-2：${interface_5g2_temperature_c}"
	if [ -n "${interface_2g_power}" -o -n "${interface_5g1_power}" -o -n "${interface_5g2_power}" ];then
		[ -n "${interface_2g_power}" ] && interface_2g_power_d="${interface_2g_power} dBm" || interface_2g_power_d="offline"
		[ -n "${interface_2g_power}" ] && interface_2g_power_p="$(awk -v x=${interface_2g_power} 'BEGIN { printf "%.2f\n", 10^(x/10)}') mw" || interface_2g_power_p="offline"
		
		[ -n "${interface_5g1_power}" ] && interface_5g1_power_d="${interface_5g1_power} dBm" || interface_5g1_power_d="offline"
		[ -n "${interface_5g1_power}" ] && interface_5g1_power_p="$(awk -v x=${interface_5g1_power} 'BEGIN { printf "%.2f\n", 10^(x/10)}') mw" || interface_5g1_power_p="offline"
		
		[ -n "${interface_5g2_power}" ] && interface_5g2_power_d="${interface_5g2_power} dBm" || interface_5g2_power_d="offline"
		[ -n "${interface_5g2_power}" ] && interface_5g2_power_p="$(awk -v x=${interface_5g2_power} 'BEGIN { printf "%.2f\n", 10^(x/10)}') mw" || interface_5g2_power_p="offline"
		wl_txpwr="2.4G：${interface_2g_power_d} / ${interface_2g_power_p} <br /> 5G-1：${interface_5g1_power_d} / ${interface_5g1_power_p} <br /> 5G-2：${interface_5g2_power_d} / ${interface_5g2_power_p}"
	else
		wl_txpwr=""
	fi
	;;
*)
	interface_2g=$(nvram get wl0_ifname)
	interface_5g1=$(nvram get wl1_ifname)
	interface_2g_temperature=$($WLEXE -i ${interface_2g} phy_tempsense | awk '{print $1}') 2>/dev/null
	interface_5g1_temperature=$($WLEXE -i ${interface_5g1} phy_tempsense | awk '{print $1}') 2>/dev/null
	[ -n "${interface_2g_temperature}" ] && interface_2g_temperature_c="$(expr ${interface_2g_temperature} / 2 + 20)°C" || interface_2g_temperature_c="offline"
	[ -n "${interface_5g1_temperature}" ] && interface_5g1_temperature_c="$(expr ${interface_5g1_temperature} / 2 + 20)°C" || interface_5g1_temperature_c="offline"
	wl_temperature="2.4G：${interface_2g_temperature_c} &nbsp;&nbsp;|&nbsp;&nbsp; 5G：${interface_5g1_temperature_c}"
	
	interface_2g_power=$($WLEXE -i ${interface_2g} txpwr_target_max | awk '{print $NF}') 2>/dev/null
	interface_5g1_power=$($WLEXE -i ${interface_5g1} txpwr_target_max | awk '{print $NF}') 2>/dev/null
	if [ -n "${interface_2g_power}" -o -n "${interface_5g1_power}" ];then
		[ -n "${interface_2g_power}" ] && interface_2g_power_d="${interface_2g_power} dBm" || interface_2g_power_d="offline"
		[ -n "${interface_2g_power}" ] && interface_2g_power_p="$(awk -v x=${interface_2g_power} 'BEGIN { printf "%.2f\n", 10^(x/10)}') mw" || interface_2g_power_p="offline"
		
		[ -n "${interface_5g1_power}" ] && interface_5g1_power_d="${interface_5g1_power} dBm" || interface_5g1_power_d="offline"
		[ -n "${interface_5g1_power}" ] && interface_5g1_power_p="$(awk -v x=${interface_5g1_power} 'BEGIN { printf "%.2f\n", 10^(x/10)}') mw" || interface_5g1_power_p="offline"
		wl_txpwr="2.4G：${interface_2g_power_d} / ${interface_2g_power_p} <br /> 5G：&nbsp;&nbsp;&nbsp;${interface_5g1_power_d} / ${interface_5g1_power_p}"
	else
		wl_txpwr=""
	fi
	;;
esac
#=================================================
http_response "${cpu_temperature}@@${wl_temperature}@@${wl_txpwr}"
