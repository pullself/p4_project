/* -*- P4_16 -*- */

#include <core.p4>
#include <v1model.p4>

// headers
#include "src/headers.p4"

// parser
#include "src/parser.p4"

// ingress control
#include "src/ingress.p4"

// egress control
#include "src/egress.p4"

// checksum control
#include "src/checksum.p4"

// deparser
#include "src/deparser.p4"

V1Switch(
	packetParser(),
	verifyChecksum(),
	ingress(),
	egress(),
	createChecksum(),
	deparser()
	) main;
