
# Verificar/Crear Proyecto
project_exist=$(openstack project show proyecto11 | grep "enabled" | grep "True" | wc -l)

# Crear el network
openstack subnet create \
    --network proyecto11-network \
    --dns-nameserver 8.8.8.8 \
    --subnet-range 10.0.0.0/24 \
    proyecto11-subnet

# Crear el router
openstack router create proyecto11-router


# INTERFACES
# Obtener el ID de la red externa ("external-network")
red_externa_id=$(openstack network show external-network -f value -c id)

# Agregar una interfaz del router a la red externa
openstack router add subnet proyecto11-router $red_externa_id

# Obtener el ID de la red interna ("proyecto11-network")
red_interna_id=$(openstack network show proyecto11-network -f value -c id)

# Agregar una interfaz del router a la red interna
openstack router add subnet proyecto11-router $red_interna_id


# GRUPO DE SEGURIDAD
# Crear grupo de seguridad
openstack security group create proyecto11-security-group

# Regla para permitir tráfico SSH (puerto 22)
openstack security group rule create --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0 proyecto11-security-group

# Regla para permitir tráfico ICMP
openstack security group rule create --protocol icmp proyecto11-security-group

# Regla para permitir tráfico HTTP al puerto 8080
openstack security group rule create --protocol tcp --dst-port 8080:8080 --remote-ip 0.0.0.0/0 proyecto11-security-group

# Regla para permitir tráfico al puerto 3306 (MySQL)
openstack security group rule create --protocol tcp --dst-port 3306:3306 --remote-ip 0.0.0.0/0 proyecto11-security-group

# Regla para permitir tráfico al puerto 5001 (iperf)
openstack security group rule create --protocol tcp --dst-port 5001:5001 --remote-ip 0.0.0.0/0 proyecto11-security-group


# VOLUMEN
openstack volume create --size 1 volume-tomcat
openstack volume create --size 1 volume-mysql


# EJECUTAR INSTANCIA

openstack server create --image ubuntu-focal --flavor labs  \
--user-data tomcat.yml \
--nic net-id=$red_interna_id \
--security-group proyecto11-security-group \
--key-name proyecto11 proyecto11-tomcat