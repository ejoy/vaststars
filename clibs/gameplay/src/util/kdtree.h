#pragma once

#include <array>
#include <limits>
#include <memory>
#include <optional>
#include <vector>

template <typename T, typename Dataset, typename AccessorType = uint16_t>
T kdtree_getdata(const Dataset& dataset, AccessorType i, uint8_t dim);

template <typename T, uint8_t DIM = 2, typename Dataset = std::vector<std::array<T, DIM>>, typename AccessorType = uint16_t>
class kdtree {
public:
    static constexpr size_t kLeafMaxSize = 10;
    using ElementType                    = T;
    using Offset                         = AccessorType;
    using Size                           = AccessorType;
    using Dimension                      = uint8_t;
    struct Node {
        union {
            struct leaf {
                Offset left, right;
            } lr;
            struct nonleaf {
                Dimension divfeat;
                ElementType divlow, divhigh;
            } sub;
        } node_type;
        std::unique_ptr<Node> child1, child2;
    };
    using NodePtr = std::unique_ptr<Node>;
    struct Interval {
        ElementType low, high;
    };
    using BoundingBox = std::array<Interval, DIM>;
    using Point       = std::array<ElementType, DIM>;

    std::vector<AccessorType> acc;
    NodePtr root_node;
    BoundingBox root_bbox;
    const Dataset& dataset;

    explicit kdtree(const Dataset& dataset)
        : dataset(dataset) { build(); }
    explicit kdtree(const kdtree&) = delete;

    void build() {
        size_t n = dataset.size();
        if (n > std::numeric_limits<Size>::max() || n == 0) {
            root_node = nullptr;
            return;
        }
        Size N = (Size)n;
        if (acc.size() != N)
            acc.resize(N);
        for (Size i = 0; i < N; ++i)
            acc[i] = i;
        for (Dimension i = 0; i < DIM; ++i) {
            root_bbox[i].low = root_bbox[i].high = kdtree_getdata<ElementType>(dataset, acc[0], i);
        }
        for (Offset k = 1; k < N; ++k) {
            for (Dimension i = 0; i < DIM; ++i) {
                ElementType v = kdtree_getdata<ElementType>(dataset, acc[k], i);
                if (v < root_bbox[i].low)
                    root_bbox[i].low = v;
                if (v > root_bbox[i].high)
                    root_bbox[i].high = v;
            }
        }
        root_node = divideTree(0, N, root_bbox);
    }

    template <typename RESULTSET>
    bool nearest(RESULTSET& result_set, const Point& query_point) const {
        if (!root_node) {
            return false;
        }
        float epsError       = 1;
        ElementType distance = ElementType();
        Point dists;
        dists.fill(0);
        for (Dimension i = 0; i < DIM; ++i) {
            if (query_point[i] < root_bbox[i].low) {
                dists[i] = result_set.accumDist(query_point[i], root_bbox[i].low);
                distance += dists[i];
            } else if (query_point[i] > root_bbox[i].high) {
                dists[i] = result_set.accumDist(query_point[i], root_bbox[i].high);
                distance += dists[i];
            }
        }
        searchLevel(result_set, query_point, root_node, distance, dists, epsError);
        return !!result_set;
    }

private:
    void computeMinMax(Offset ind, Size count, Dimension element, ElementType& min_elem, ElementType& max_elem) {
        min_elem = kdtree_getdata<ElementType>(dataset, acc[ind], element);
        max_elem = min_elem;
        for (Offset i = 1; i < count; ++i) {
            ElementType val = kdtree_getdata<ElementType>(dataset, acc[ind + i], element);
            if (val < min_elem) min_elem = val;
            if (val > max_elem) max_elem = val;
        }
    }

    NodePtr divideTree(Offset left, Offset right, BoundingBox& bbox) {
        NodePtr node = std::make_unique<Node>();

        if ((right - left) <= static_cast<Offset>(kLeafMaxSize)) {
            node->child1.reset();
            node->child2.reset();
            node->node_type.lr.left  = left;
            node->node_type.lr.right = right;

            for (Dimension i = 0; i < DIM; ++i) {
                ElementType v = kdtree_getdata<ElementType>(dataset, acc[left], i);
                bbox[i].low   = v;
                bbox[i].high  = v;
            }
            for (Offset k = left + 1; k < right; ++k) {
                for (Dimension i = 0; i < DIM; ++i) {
                    ElementType v = kdtree_getdata<ElementType>(dataset, acc[k], i);
                    if (bbox[i].low > v)
                        bbox[i].low = v;
                    if (bbox[i].high < v)
                        bbox[i].high = v;
                }
            }
        } else {
            Offset idx;
            Dimension cutfeat;
            ElementType cutval;
            middleSplit(left, right - left, idx, cutfeat, cutval, bbox);

            node->node_type.sub.divfeat = cutfeat;

            BoundingBox left_bbox(bbox);
            left_bbox[cutfeat].high = cutval;
            node->child1            = divideTree(left, left + idx, left_bbox);

            BoundingBox right_bbox(bbox);
            right_bbox[cutfeat].low = cutval;
            node->child2            = divideTree(left + idx, right, right_bbox);

            node->node_type.sub.divlow  = left_bbox[cutfeat].high;
            node->node_type.sub.divhigh = right_bbox[cutfeat].low;

            for (Dimension i = 0; i < DIM; ++i) {
                bbox[i].low  = std::min(left_bbox[i].low, right_bbox[i].low);
                bbox[i].high = std::max(left_bbox[i].high, right_bbox[i].high);
            }
        }
        return node;
    }

    void middleSplit(Offset ind, Size count, Offset& index, Dimension& cutfeat, ElementType& cutval, const BoundingBox& bbox) {
        auto EPS             = static_cast<ElementType>(0.00001);
        ElementType max_span = bbox[0].high - bbox[0].low;
        for (Dimension i = 1; i < DIM; ++i) {
            ElementType span = bbox[i].high - bbox[i].low;
            if (span > max_span) {
                max_span = span;
            }
        }
        ElementType max_spread = -1;
        cutfeat                = 0;
        for (Dimension i = 0; i < DIM; ++i) {
            ElementType span = bbox[i].high - bbox[i].low;
            if (span > (1 - EPS) * max_span) {
                ElementType min_elem, max_elem;
                computeMinMax(ind, count, i, min_elem, max_elem);
                ElementType spread = max_elem - min_elem;
                if (spread > max_spread) {
                    cutfeat    = i;
                    max_spread = spread;
                }
            }
        }
        ElementType split_val = (bbox[cutfeat].low + bbox[cutfeat].high) / 2;
        ElementType min_elem, max_elem;
        computeMinMax(ind, count, cutfeat, min_elem, max_elem);

        if (split_val < min_elem)
            cutval = min_elem;
        else if (split_val > max_elem)
            cutval = max_elem;
        else
            cutval = split_val;

        Offset lim1, lim2;
        planeSplit(ind, count, cutfeat, cutval, lim1, lim2);

        if (lim1 > count / 2)
            index = lim1;
        else if (lim2 < count / 2)
            index = lim2;
        else
            index = count / 2;
    }

    void planeSplit(Offset ind, Size count, Dimension cutfeat, ElementType& cutval, Offset& lim1, Offset& lim2) {
        Offset left  = 0;
        Offset right = count - 1;
        for (;;) {
            while (left <= right && kdtree_getdata<ElementType>(dataset, acc[ind + left], cutfeat) < cutval)
                ++left;
            while (right && left <= right && kdtree_getdata<ElementType>(dataset, acc[ind + right], cutfeat) >= cutval)
                --right;
            if (left > right || !right)
                break;
            std::swap(acc[ind + left], acc[ind + right]);
            ++left;
            --right;
        }
        lim1  = left;
        right = count - 1;
        for (;;) {
            while (left <= right && kdtree_getdata<ElementType>(dataset, acc[ind + left], cutfeat) <= cutval)
                ++left;
            while (right && left <= right && kdtree_getdata<ElementType>(dataset, acc[ind + right], cutfeat) > cutval)
                --right;
            if (left > right || !right)
                break;
            std::swap(acc[ind + left], acc[ind + right]);
            ++left;
            --right;
        }
        lim2 = left;
    }

    template <class RESULTSET>
    bool searchLevel(RESULTSET& result_set, const Point& pt, const NodePtr& node, ElementType mindistsq, Point& dists, float epsError) const {
        if ((node->child1 == nullptr) && (node->child2 == nullptr)) {
            ElementType worst_dist = result_set.worstDist();
            for (Offset i = node->node_type.lr.left; i < node->node_type.lr.right; ++i) {
                AccessorType accessor = acc[i];
                ElementType distance  = ElementType();
                for (Dimension i = 0; i < DIM; ++i) {
                    distance += result_set.accumDist(pt[i], kdtree_getdata<ElementType>(dataset, accessor, i));
                }
                if (distance < worst_dist) {
                    if (!result_set.addPoint(dataset, distance, accessor)) {
                        return false;
                    }
                }
            }
            return true;
        }

        Dimension idx     = node->node_type.sub.divfeat;
        ElementType val   = pt[idx];
        ElementType diff1 = val - node->node_type.sub.divlow;
        ElementType diff2 = val - node->node_type.sub.divhigh;

        const NodePtr* bestChild;
        const NodePtr* otherChild;
        ElementType cut_dist;
        if ((diff1 + diff2) < 0) {
            bestChild  = &node->child1;
            otherChild = &node->child2;
            cut_dist   = result_set.accumDist(val, node->node_type.sub.divhigh);
        } else {
            bestChild  = &node->child2;
            otherChild = &node->child1;
            cut_dist   = result_set.accumDist(val, node->node_type.sub.divlow);
        }

        if (!searchLevel(result_set, pt, *bestChild, mindistsq, dists, epsError)) {
            return false;
        }

        ElementType dst = dists[idx];
        mindistsq       = mindistsq + cut_dist - dst;
        dists[idx]      = cut_dist;
        if (mindistsq * epsError <= result_set.worstDist()) {
            if (!searchLevel(result_set, pt, *otherChild, mindistsq, dists, epsError)) {
                return false;
            }
        }
        dists[idx] = dst;
        return true;
    }
};
