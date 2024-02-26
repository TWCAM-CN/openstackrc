# NETWORK
# Crear el network
echo "Creando Network..."
openstack network create proyecto11-network
echo ""

echo "Creando SubNet..."
# Asociar
openstack subnet create \
    --network proyecto11-network \
    --dns-nameserver 8.8.8.8 \
    --subnet-range 10.0.0.0/24 \
     proyecto11-subnet
echo ""

# ROUTER
# Crear el router
echo "Creando Router..."
openstack router create proyecto11-router
echo ""


# INTERFACES
# Obtener el ID de la red interna ("proyecto11-network")
# red_interna_id=$(openstack network show proyecto11-network -f value -c id)
# echo "Red interna ID: $red_interna_id"
# echo ""

# Agregar una interfaz del router a la red interna
echo "Vinculando Red-Interna a Router"
openstack router add subnet proyecto11-router proyecto11-network
echo ""

# Obtener el ID de la red externa ("external-network")
red_externa_id=$(openstack network show external-network -f value -c id)
echo "Red externa ID: $red_externa_id"
echo ""

# Agregar una interfaz del router a la red externa
echo "Vinculando SubNet-Externa a Router"
openstack router set --external-gateway $red_externa_id proyecto11-router
echo ""


# GRUPO DE SEGURIDAD
# Crear grupo de seguridad
echo "Creando Grupo de Seguridad"
openstack security group create proyecto11-security-group
echo ""

# Regla para permitir tráfico SSH (puerto 22)
echo "Creando regla seguridad SSH"
openstack security group rule create --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0 proyecto11-security-group
echo ""

# Regla para permitir tráfico ICMP
echo "Creando regla de seguridad ICMP"
openstack security group rule create --protocol icmp proyecto11-security-group
echo ""

# Regla para permitir tráfico HTTP al puerto 8080
echo "Creando regla de seguridad HTTP"
openstack security group rule create --protocol tcp --dst-port 8080:8080 --remote-ip 0.0.0.0/0 proyecto11-security-group
echo ""

# Regla para permitir tráfico al puerto 3306 (MySQL)
echo "Creando regla de seguridad MySQL"
openstack security group rule create --protocol tcp --dst-port 3306:3306 --remote-ip 0.0.0.0/0 proyecto11-security-group
echo ""

# Regla para permitir tráfico al puerto 5001 (iperf)
echo "Creando regla de seguridad IPERF"
openstack security group rule create --protocol tcp --dst-port 5001:5001 --remote-ip 0.0.0.0/0 proyecto11-security-group
echo ""


# VOLUMEN
echo "Creando volumen Tomcat"
openstack volume create --size 1 volume-tomcat
echo ""

echo "Creando volumen Mysqls"
openstack volume create --size 1 volume-mysql