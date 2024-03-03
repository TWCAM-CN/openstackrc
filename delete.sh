#!/bin/bash

# COMPROBACIONES PREVIAS Y ELIMINACIÓN DE INSTANCIAS
# Eliminar instancia de Tomcat
echo "Verificando y eliminando instancia de Tomcat..."
if openstack server show proyecto11-instance-tomcat -f value -c id &>/dev/null; then
    openstack server delete proyecto11-instance-tomcat
    echo "Instancia de Tomcat eliminada correctamente."
else
    echo "Instancia de Tomcat no existe."
fi
echo ""

# Eliminar instancia de MySQL
echo "Verificando y eliminando instancia de MySQL..."
if openstack server show proyecto11-instance-mysql -f value -c id &>/dev/null; then
    openstack server delete proyecto11-instance-mysql
    echo "Instancia de MySQL eliminada correctamente."
else
    echo "Instancia de MySQL no existe."
fi
echo ""

# ELIMINACIÓN DE IP FLOTANTE
# Tomcat
echo "Verificando y eliminando IP Flotante de Tomcat..."
tomcat_floating_ip_id=$(openstack floating ip list --long | grep "proyeto11-floatingip-tomcat" | awk '{print $2}')
if [ ! -z "$tomcat_floating_ip_id" ]; then
    openstack floating ip delete $tomcat_floating_ip_id
    echo "IP Flotante de Tomcat eliminada correctamente."
else
    echo "IP Flotante de Tomcat no existe."
fi
echo ""

# MySQL
echo "Verificando y eliminando IP Flotante de MySQL..."
mysql_floating_ip_id=$(openstack floating ip list --long | grep "proyeto11-floatingip-mysql" | awk '{print $2}')
if [ ! -z "$mysql_floating_ip_id" ]; then
    openstack floating ip delete $mysql_floating_ip_id
    echo "IP Flotante de MySQL eliminada correctamente."
else
    echo "IP Flotante de MySQL no existe."
fi
echo ""

# VOLUMENES
# Verificar y eliminar volumen Tomcat
echo "Verificando y eliminando volumen Tomcat..."
if openstack volume show proyecto11-volume-tomcat -f value -c id &>/dev/null; then
    openstack volume delete proyecto11-volume-tomcat
    echo "Volumen Tomcat eliminado correctamente."
else
    echo "Volumen Tomcat no existe."
fi
echo ""

# Verificar y eliminar volumen MySQL
echo "Verificando y eliminando volumen MySQL..."
if openstack volume show proyecto11-volume-mysql -f value -c id &>/dev/null; then
    openstack volume delete proyecto11-volume-mysql
    echo "Volumen MySQL eliminado correctamente."
else
    echo "Volumen MySQL no existe."
fi
echo ""

# GRUPO DE SEGURIDAD
echo "Verificando y eliminando Grupo de Seguridad..."
if openstack security group show proyecto11-security-group -f value -c id &>/dev/null; then
    openstack security group delete proyecto11-security-group
    echo "Grupo de Seguridad eliminado correctamente."
else
    echo "Grupo de Seguridad no existe."
fi
echo ""

# ROUTER
echo "Verificando y desvinculando Red-Interna del Router..."
if openstack router show proyecto11-router -f value -c id &>/dev/null; then
    openstack router remove subnet proyecto11-router proyecto11-subnet &>/dev/null
    echo "Red-Interna desvinculada del Router correctamente."
    
    echo "Desvinculando Red-Externa del Router..."
    openstack router unset --external-gateway proyecto11-router &>/dev/null
    echo "Red-Externa desvinculada del Router correctamente."
    
    echo "Eliminando Router..."
    openstack router delete proyecto11-router
    echo "Router eliminado correctamente."
else
    echo "Router no existe."
fi
echo ""

# SUBNET
echo "Verificando y eliminando SubNet..."
if openstack subnet show proyecto11-subnet -f value -c id &>/dev/null; then
    openstack subnet delete proyecto11-subnet
    echo "SubNet eliminada correctamente."
else
    echo "SubNet no existe."
fi
echo ""

# NETWORK
echo "Verificando y eliminando Network..."
if openstack network show proyecto11-network -f value -c id &>/dev/null; then
    openstack network delete proyecto11-network
    echo "Network eliminada correctamente."
else
    echo "Network no existe."
fi
echo ""

echo "Proceso de eliminación completado."
