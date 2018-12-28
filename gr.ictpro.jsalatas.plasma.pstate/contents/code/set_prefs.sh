#!/bin/bash

INTEL_PSTATE=/sys/devices/system/cpu/intel_pstate
CPU_MIN_PERF=$INTEL_PSTATE/min_perf_pct
CPU_MAX_PERF=$INTEL_PSTATE/max_perf_pct
CPU_TURBO=$INTEL_PSTATE/no_turbo

GPU=/sys/class/drm/card0
GPU_MIN_FREQ=$GPU/gt_min_freq_mhz
GPU_MAX_FREQ=$GPU/gt_max_freq_mhz
GPU_MIN_LIMIT=$GPU/gt_RP1_freq_mhz
GPU_MAX_LIMIT=$GPU/gt_RP0_freq_mhz
GPU_BOOST_FREQ=$GPU/gt_boost_freq_mhz
GPU_CUR_FREQ=$GPU/gt_cur_freq_mhz

check_dell_thermal () {
    smbios-thermal-ctl -g > /dev/null 2>&1 
    OUT=$?
    if [ $OUT -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

set_cpu_min_perf () {
    minperf=$1
    if [ -n "$minperf" ] && [ "$minperf" != "0" ]; then
        printf '%s\n' "$minperf" > $CPU_MIN_PERF; 2> /dev/null
    fi
}

set_cpu_max_perf () {
    maxperf=$1
    if [ -n "$maxperf" ] && [ "$maxperf" != "0" ]; then
        printf '%s\n' "$maxperf" > $CPU_MAX_PERF; 2> /dev/null
    fi
}

set_cpu_turbo () {
    turbo=$1
    if [ -n "$turbo" ]; then
        if [ "$turbo" == "true" ]; then
            printf '0\n' > $CPU_TURBO; 2> /dev/null
        else
            printf '1\n' > $CPU_TURBO; 2> /dev/null
        fi
    fi
}

set_gpu_min_freq () {
    gpuminfreq=$1
    if [ -n "$gpuminfreq" ] && [ "$gpuminfreq" != "0" ]; then
        printf '%s\n' "$gpuminfreq" > $GPU_MIN_FREQ; 2> /dev/null
    fi
}

set_gpu_max_freq () {
    gpumaxfreq=$1
    if [ -n "$gpumaxfreq" ] && [ "$gpumaxfreq" != "0" ]; then
        printf '%s\n' "$gpumaxfreq" > $GPU_MAX_FREQ; 2> /dev/null
    fi
}

set_gpu_boost_freq () {
    gpuboostfreq=$1
    if [ -n "$gpuboostfreq" ] && [ "$gpuboostfreq" != "0" ]; then
        printf '%s\n' "$gpuboostfreq" > $GPU_BOOST_FREQ; 2> /dev/null
    fi
}

set_cpu_governor () {
    gov=$1
    if [ -n "$gov" ]; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            printf '%s\n' "$gov" > $cpu; 2> /dev/null
        done
    fi
}

set_energy_perf () {
    energyperf=$1
    if [ -n "$energyperf" ]; then
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
            printf '%s\n' "$energyperf" > $cpu; 2> /dev/null
        done
    fi
}

set_thermal_mode () {
    smbios-thermal-ctl --set-thermal-mode=$1 2> /dev/null 
}

read_all () {
cpu_min_perf=`cat $CPU_MIN_PERF`
cpu_max_perf=`cat $CPU_MAX_PERF`
cpu_turbo=`cat $CPU_TURBO`
if [ "$cpu_turbo" == "1" ]; then
    cpu_turbo="false"
else
    cpu_turbo="true"
fi
gpu_min_freq=`cat $GPU_MIN_FREQ`
gpu_max_freq=`cat $GPU_MAX_FREQ`
gpu_min_limit=`cat $GPU_MIN_LIMIT`
gpu_max_limit=`cat $GPU_MAX_LIMIT`
gpu_boost_freq=`cat $GPU_BOOST_FREQ`
gpu_cur_freq=`cat $GPU_CUR_FREQ`
cpu_governor=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
energy_perf=`cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference`
if check_dell_thermal; then
    thermal_mode=`smbios-thermal-ctl -g | grep -C 1 "Current Thermal Modes:"  | tail -n 1 | awk '{$1=$1;print}' | sed "s/\t//g" | sed "s/ /-/g" | tr [A-Z] [a-z] `
fi
json="{"
json="${json}\"cpu_min_perf\":\"${cpu_min_perf}\""
json="${json},\"cpu_max_perf\":\"${cpu_max_perf}\""
json="${json},\"cpu_turbo\":\"${cpu_turbo}\""
json="${json},\"gpu_min_freq\":\"${gpu_min_freq}\""
json="${json},\"gpu_max_freq\":\"${gpu_max_freq}\""
json="${json},\"gpu_min_limit\":\"${gpu_min_limit}\""
json="${json},\"gpu_max_limit\":\"${gpu_max_limit}\""
json="${json},\"gpu_boost_freq\":\"${gpu_boost_freq}\""
json="${json},\"gpu_cur_freq\":\"${gpu_cur_freq}\""
json="${json},\"cpu_governor\":\"${cpu_governor}\""
json="${json},\"energy_perf\":\"${energy_perf}\""
if check_dell_thermal; then
    json="${json},\"thermal_mode\":\"${thermal_mode}\""
fi
json="${json}}"
echo $json
}

case $1 in
    "-cpu-min-perf")
        set_cpu_min_perf $2
        ;;

    "-cpu-max-perf")
        set_cpu_max_perf $2
        ;;

    "-cpu-turbo")
        set_cpu_turbo $2
        ;;

    "-gpu-min-freq")
        set_gpu_min_freq $2
        ;;

    "-gpu-max-freq")
        set_gpu_max_freq $2
        ;;

    "-gpu-boost-freq")
        set_gpu_boost_freq $2
        ;;

    "-cpu-governor")
        set_cpu_governor $2
        ;;

    "-energy-perf")
        set_energy_perf $2
        ;;

    "-thermal-mode")
        set_thermal_mode $2
        ;;

    "-read-all")
        read_all
        ;;

    *)
        echo "Usage:"
        echo "1: set_prefs.sh [ -cpu-min-perf   |"
        echo "                  -cpu-max-perf   |"
        echo "                  -cpu-turbo      |"
        echo "                  -gpu-min-freq   |"
        echo "                  -gpu-max-freq   |"
        echo "                  -gpu-boost-freq |"
        echo "                  -cpu-governor   |"
        echo "                  -energy-perf    |"
        echo "                  -thermal-mode ] value"
        echo "2: set_prefs.sh -read-all"
        exit 3
        ;;
esac



















