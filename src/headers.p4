// standard_metadata的instance_type字段
#define PKT_INSTANCE_TYPE_NORMAL 0
#define PKT_INSTANCE_TYPE_INGRESS_CLONE 1
#define PKT_INSTANCE_TYPE_EGRESS_CLONE 2
#define PKT_INSTANCE_TYPE_COALESCED 3
#define PKT_INSTANCE_TYPE_INGRESS_RECIRC 4
#define PKT_INSTANCE_TYPE_REPLICATION 5
#define PKT_INSTANCE_TYPE_RESUBMIT 6
#define CONTROLLER_PORT 16 // 默认控制器端口

#define PROTECTION_STORAGE 8192 //保护序号容量
#define SEQ_MAX 255 //8bit的序列号上限

// 地址规范
typedef bit<9> egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;
typedef bit<16> protectionId_t;
typedef bit<16> mcastGrp_t; // 组播类
typedef bit<8> protectionSeq_t; // 保护序列类

// 协议标志
const bit<16> TYPE_IPV4 = 0x0800;
const bit<16> TYPE_DISCOVER = 0xDD00;
// (ETH)定义保护标头协议类号
const bit<16> TYPE_PROTECTION = 0xDD01; //以太网协议字段下表明保护报头
const bit<16> TYPE_PROTECTION_RESET = 0xDD02; //以太网协议字段下表明保护重置报文
const bit<8> TYPE_TCP = 6;
const bit<8> TYPE_UDP = 17;
// (IP)定义保护规范下使用的协议类号
const bit<8> TYPE_IP_PROTECTION = 0x8F; //ip协议字段下表明保护报头
const bit<8> TYPE_IP_IP = 0x04; //protection协议字段下表明ip报头


// 拓扑发现 header
header topology_discover_t {
    bit<32> identifier;
    bit<16> port;
    bit<32> prefix;
    bit<48> mac;
}

// 以太网头
header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16> etherType;
}

// ip头
header ipv4_t {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffServ;
    bit<16> totalLen;
    bit<16> identification;
    bit<3> flags;
    bit<13> fragOffset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdrCheckSum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

// 传输层头
// 其余字段忽略，不需要使用到
header transport_t {
    bit<16> src_port;
    bit<16> dst_port;
}

// 保护头
header protection_t {
    protectionId_t  conn_id;    
    protectionSeq_t seq;
    bit<8>          proto;
}

// 待解决
header protection_reset_t {
    bit<32>         conn_id;
    bit<32>         device_type;
}

struct headers {
    ethernet_t ethernet;
    protection_t protection;
    protection_reset_t protection_reset;
    ipv4_t ipv4;
    transport_t transport;
    ipv4_t ipv4_inner;
    topology_discover_t topology;
}

// 个人metadata
struct intrinsic_metadata_t {
    bit<48> ingress_global_timestamp;
    bit<48> egress_global_timestamp;
    bit<32> lf_field_list;
    bit<16> mcast_grp;
    bit<32> resubmit_flag;
    bit<16> egress_rid;
    bit<32> recirculate_flag;
}

struct test_t {
    bit<8> digest;
    bit<32> srcIP;
    bit<32> dstIP;
}

struct metadata {
    intrinsic_metadata_t intrinsic_metadata;
    test_t test;
}

