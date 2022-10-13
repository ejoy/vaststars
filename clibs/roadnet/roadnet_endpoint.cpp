#include "roadnet_endpoint.h"
#include "roadnet_world.h"

namespace roadnet {
    static constexpr uint8_t kTime = 10;

    void endpointManager::init(const std::vector<uint16_t>& endpoints) {
        for (auto offset : endpoints) {
            this->endpoints[offset].pushMap = std::list<lorryid>();
            this->endpoints[offset].popMap = std::list<lorryid>();
        }
    }
    void endpointManager::pushLorry(lorryid l, uint16_t offset) {
        auto iter = endpoints.find(offset);
        assert(iter != endpoints.end());
        iter->second.pushMap.push_back(l);
    }
    lorryid endpointManager::popLorry(uint16_t offset) {
        auto iter = endpoints.find(offset);
        assert(iter != endpoints.end());
        if (iter->second.popMap.empty()) {
            return lorryid::invalid();
        }
        auto l = iter->second.popMap.front();
        iter->second.popMap.pop_front();
        return l;
    }
    bool endpointManager::tryEntry(world& w, uint16_t offset, lorryid id) {
        auto iter = endpoints.find(offset);
        assert(iter != endpoints.end());
        auto& e = iter->second;
        if (e.lorry[endpoint::IN] != lorryid::invalid()) {
            return false;
        }
        e.lorry[endpoint::IN] = id;
        auto& l = w.Lorry(id);
        l.initTick(kTime);
        return true;
    }
    lorryid endpointManager::getLorry(world& w, uint16_t offset) {
        auto iter = endpoints.find(offset);
        if( iter == endpoints.end() ) {
            return lorryid::invalid();
        }
        auto& e = iter->second;
        return e.lorry[endpoint::OUT];
    }
    void endpointManager::exit(world& w, uint16_t offset) {
        auto iter = endpoints.find(offset);
        if( iter == endpoints.end() ) {
            return;
        }
        auto& e = iter->second;
        e.lorry[endpoint::OUT] = lorryid::invalid();
    }
    void endpointManager::update(world& w) {
        for (auto& [offset, e] : endpoints) {
            auto l = e.lorry[endpoint::IN];
            if (l != lorryid::invalid()) {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    e.popMap.push_back(e.lorry[endpoint::IN]);
                    e.lorry[endpoint::IN] = lorryid::invalid();
                }
            }

            l = e.lorry[endpoint::OUT];
            if (l == lorryid::invalid() && e.pushMap.size() > 0) {
                e.lorry[endpoint::OUT] = e.pushMap.front();
                e.pushMap.pop_front();
            }
        }
    }
}