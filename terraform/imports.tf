# Adopt what was built by hand in the dashboard. Each block says:
# "this existing object in incident.io is now this address in Terraform".

import {
  to = module.alert_routing.incident_alert_source.source
  id = "01M4N0A1XG6A5STJ6N68D76614"
}

import {
  to = module.alert_routing.incident_alert_attribute.service
  id = "bc2322eb-8cb0-46a1-9895-a3401e8fa81b"
}

import {
  to = module.alert_routing.incident_alert_attribute.runbook
  id = "dbacdbd9-847b-4664-8cf3-f72f78560e4e"
}

import {
  to = module.alert_routing.incident_alert_source_attribute.team
  id = "01M4N0A1XG6A5STJ6N68D76614:01M4MXHV3FB9PK0GPN2VKXFRGH"
}

import {
  to = module.alert_routing.incident_alert_source_attribute.service
  id = "01M4N0A1XG6A5STJ6N68D76614:bc2322eb-8cb0-46a1-9895-a3401e8fa81b"
}

import {
  to = module.alert_routing.incident_alert_source_attribute.runbook
  id = "01M4N0A1XG6A5STJ6N68D76614:dbacdbd9-847b-4664-8cf3-f72f78560e4e"
}

import {
  to = module.alert_routing.incident_alert_route.this
  id = "01M4N8FKPSGTT4D760PVM987YP"
}

import {
  to = module.alert_routing.incident_incident_template.alert_incident
  id = "01M4P9VTTC6TPD4Y2SJ2KXBH98"
}

import {
  to = module.alert_routing.incident_escalation_path_template.team_then_backstop
  id = "01M4N48BP6KX0H5YNWWPCXRM83"
}

import {
  to = module.alert_routing.incident_escalation_path.backstop
  id = "01M4N3MSPVKP7HGDTKS4WKTDT6"
}

import {
  to = module.alert_routing.incident_escalation_path.team["streaming"]
  id = "01M4N4KNNJ73KEMBW85EBQ4EEK"
}

import {
  to = module.alert_routing.incident_escalation_path.team["api"]
  id = "01M4N4MGE2TW8FXBJVM8E4QZTT"
}

import {
  to = module.alert_routing.incident_escalation_path.team["cdn"]
  id = "01M4N4NEQKB8YYV1HQEFB3N4SB"
}

import {
  to = module.alert_routing.incident_escalation_path.team["databases"]
  id = "01M4N4P13FGQKNSFY1G5ZAKNSE"
}

import {
  to = module.alert_routing.incident_schedule.team["sre"]
  id = "01M4N355A951B9FJTDDWYJ3SW7"
}

import {
  to = module.alert_routing.incident_schedule_rotation.team["sre"]
  id = "01M4N355A951B9FJTDDWYJ3SW7:01M4N2T14NAZRY6JNJAEAKXGV9"
}

import {
  to = module.alert_routing.incident_schedule.team["streaming"]
  id = "01M4N36635R9E2Y640R6V0H4C0"
}

import {
  to = module.alert_routing.incident_schedule_rotation.team["streaming"]
  id = "01M4N36635R9E2Y640R6V0H4C0:01M4N35CETR8EEQB7TBXQM5ZFW"
}

import {
  to = module.alert_routing.incident_schedule.team["api"]
  id = "01M4N383JK8FQFVDYX2V0QFQ9A"
}

import {
  to = module.alert_routing.incident_schedule_rotation.team["api"]
  id = "01M4N383JK8FQFVDYX2V0QFQ9A:01M4N36GFJJ4WHF0ECCMH8TNBD"
}

import {
  to = module.alert_routing.incident_schedule.team["cdn"]
  id = "01M4N39FPDC0KRY18NSNVK3V9E"
}

import {
  to = module.alert_routing.incident_schedule_rotation.team["cdn"]
  id = "01M4N39FPDC0KRY18NSNVK3V9E:01M4N38FRPM9WF4A4XNZNRK1WE"
}

import {
  to = module.alert_routing.incident_schedule.team["databases"]
  id = "01M4N3ADYFNV55CGWY00NE0EC1"
}

import {
  to = module.alert_routing.incident_schedule_rotation.team["databases"]
  id = "01M4N3ADYFNV55CGWY00NE0EC1:01M4N39RG15909H6GSVT8GJTW9"
}

import {
  to = module.alert_routing.incident_catalog_type.team
  id = "01M4MXHTZKJKRN4D6XB962WE0Y"
}

import {
  to = module.alert_routing.incident_catalog_type.service
  id = "01M4N6265RT6EANFR7Y571WRJK"
}

import {
  to = module.alert_routing.incident_catalog_type_attribute.service_owner
  id = "01M4N6265RT6EANFR7Y571WRJK:01M4N61JEVKHRTMQHBY2DD0BH0"
}

import {
  to = module.alert_routing.incident_catalog_type_attribute.service_lifecycle
  id = "01M4N6265RT6EANFR7Y571WRJK:01M4P5MQNST7RT6ZPARC37K7WW"
}

import {
  to = module.alert_routing.incident_catalog_type_attribute.service_tier
  id = "01M4N6265RT6EANFR7Y571WRJK:01M4P5N5RQ4FH8PRGFGK2142TD"
}

import {
  to = module.alert_routing.incident_catalog_entries.team
  id = "01M4MXHTZKJKRN4D6XB962WE0Y"
}

import {
  to = module.alert_routing.incident_catalog_entries.service
  id = "01M4N6265RT6EANFR7Y571WRJK"
}

