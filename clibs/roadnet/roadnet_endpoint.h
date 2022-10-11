#pragma once

#include "roadnet_type.h"
#include <list>
#include <map>

namespace roadnet {
    struct endpoint {
        std::list<lorryid> pushMap;
        std::list<lorryid> popMap;
    };

    struct straight_endpoints {
        std::map<uint16_t, endpoint> endpoints; // offset -> endpoint

        void init(const std::vector<uint16_t>& endpoints) {
            for (auto offset : endpoints) {
                this->endpoints[offset].pushMap = std::list<lorryid>();
                this->endpoints[offset].popMap = std::list<lorryid>();
            }
        }
        void pushLorry(lorryid l, uint16_t offset) {
            auto iter = endpoints.find(offset);
            assert(iter != endpoints.end());
            iter->second.pushMap.push_back(l);
        }
        lorryid popLorry(uint16_t offset) {
            auto iter = endpoints.find(offset);
            assert(iter != endpoints.end());
            if (iter->second.popMap.empty()) {
                return lorryid::invalid();
            }
            auto l = iter->second.popMap.front();
            iter->second.popMap.pop_front();
            return l;
        }
        lorryid front(uint16_t offset) {
            auto iter = endpoints.find(offset);
            if( iter == endpoints.end() ) {
                return lorryid::invalid();
            }
            auto& e = iter->second;
            auto l = e.pushMap.front();
            if (l == *e.pushMap.end()) {
                return lorryid::invalid();
            }
            return l;
        }
        void pop_front(uint16_t offset) {
            auto iter = endpoints.find(offset);
            assert(iter != endpoints.end());
            iter->second.pushMap.pop_front();
        }
    };
}
