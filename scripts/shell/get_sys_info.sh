#!/system/bin/sh

function usage()
{
    echo

cat 0<< EOF
Usage:
-t     top info
-p     ps info
-s     dumpsys info
-d     dumpstate info
-n NUM run times
EOF

    echo
}

function topinfo()
{
    echo "exec top -m 10 -n 1 -H ..."
    date >> ${log_dir}/top.log
    echo -e "\ntop, ${log_suffix}\n" >> ${log_dir}/top.log
    top -m 10 -n 2 -d 1 >> ${log_dir}/top.log
}

function psinfo()
{
    echo "exec ps -t -x -p -P -c ..."
    date >> ${log_dir}/ps.log${log_suffix}
    ps -t -x -p -P -c >> ${log_dir}/ps.log${log_suffix}
}

function dumpsys_respective()
{
    service_list=`service list | busybox cut -f2 | busybox cut -d':' -f1 | grep -iEv "Found.*services"`

    for service_ in ${service_list}
    do
        echo "dumpsys ${service_}"
        echo "dumpsys ${service_}" >> ${log_dir}/dumpsys.log${log_suffix}
        dumpsys ${service_} >> ${log_dir}/dumpsys.log${log_suffix}
    done
}

function dumpstateinfo()
{
    echo "exec dumpstate ..."
    dumpstate >> ${log_dir}/dumpstate.log${log_suffix}
}


if [ $# -eq 0 ]; then
    usage
    exit 1
fi

parameter=
log_suffix=
log_dir=/data/local/tmp/log

if [ ! -d ${log_dir} ]; then
    mkdir -p ${log_dir}
fi

if [ $? -ne 0 ]; then
    echo "mkdir log dir failed."
    exit 1
fi

while getopts ":tpsdn:" optn;
do
    case ${optn} in
    t)
        parameter="${parameter} "t;;
    p)
        parameter="${parameter} "p;;
    s)
        parameter="${parameter} "s;;
    d)
        parameter="${parameter} "d;;
    n)
        times=$OPTARG;;
    :)
        echo " $OPTARG missing option argument"
        echo;;
    *)
        echo "unknown parameter $OPTARG"
        echo;;
    esac
done

for i in $(seq 0 ${times})
do
    log_suffix=${i}
    for var in $parameter
    do
        case ${var} in
        t)
            topinfo;;
        p)
            psinfo;;
        s)
            dumpsys_respective;;
        d)
            dumpstateinfo;;
        esac
    done
done

echo "get system info finishes!"
