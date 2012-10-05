require 'snmp'

# get gateway IP
gateway = `ip route show`.match(/default.*/)[0].match(
  /\d\d?\d?\.\d\d?\d?\.\d\d?\d?\.\d\d?\d?/
)[0]

# get mask
mask = `ip route show`.match(/.*src.*/)[0].match(/\/\d\d/)[0].match(/\d\d/)

system("fping -q -g #{gateway}/#{mask} > /dev/null 2>&1")

ifTable_columns = ["ipNetToMediaPhysAddress", "ipNetToMediaNetAddress"]

puts "MAC\t\t\tIP"

SNMP::Manager.open(Host: gateway, Community: 'mostronave') do |manager|
  manager.walk(ifTable_columns) do |row|
    row.each_with_index do |vb, i|
      if i == 0 
        if vb.value.unpack('H2H2H2H2H2H2').join(':') != 'ff:ff:ff:ff:ff:ff' and vb.value.unpack('H2H2H2H2H2H2').join(':') != '00:00:00:00:00:00'
          print "#{vb.value.unpack('H2H2H2H2H2H2').join(':')}\t"
        else
         break 
        end
      else
        print "#{vb.value}\t"
        puts
      end
    end
  end
end
