# Para eliminar el contenido hay que hacerlo de abajo hacia arriba:
# 1. Verificar que no hay una IPFlotante asignada, de lo contrario eliminarla
openstack floating ip delete <IP_flotante>

# Eliminar GrupSeg, Rout, Volu 

# 2. Eliminar subnet
openstack subnet delete  proyecto11-subnet

# 3. Eliminar network
openstack network delete  proyecto11-network
