# install a ganglia statistic web server
include ganglia::gmetad

ganglia::gmond {
    "${hostname} gmond instance":
    cluster => "SomeCluster",
    # Use whatever multicast address your gmetad is listening on
    mcast_address => "239.2.11.73"
}

