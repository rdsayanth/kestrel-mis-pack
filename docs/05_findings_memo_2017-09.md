# Monthly Commentary — September 2017

**To:** Head of Operations, Commercial Manager, Finance Business Partner
**From:** Sayanth Rajani Divakaran, Reporting Analyst
**Re:** Kestrel Sports Supply MIS pack, September 2017
**Data status:** September loaded and reconciled to control totals (5,189 lines, 1,723 orders, $1,027,111.73 net sales on all orders). All 18 checks pass after one reference-list update (see §5).

> Kestrel Sports Supply is a simulated business built on the public DataCo Smart Supply Chain dataset. This dataset is synthetic, and some of its patterns are fixed by construction (see DQ-09). The recommendations below are the questions an analyst would put to the business. They are not proven causes.

---

## Summary

1. **Net sales of $976.9k were the highest of the 33 months on record** (+1.9% vs August, +12.5% vs September 2016, target +3%). The growth came from higher order values, not more orders.
2. **On-time delivery is 42.6% against a 50% target, and this is a structural problem rather than a September one.** It has stayed between 40.1% and 45.0% in every month. Premium shipping modes account for most of the gap.
3. **Cancellations rose to 4.8%** (target 4.0%; Off track).
4. **Eight products made a loss, totalling $4,064.** The two largest are elliptical trainers sold for the first time this month.
5. **A new category, "Basketball", arrived with products that do not belong in it.** The reconciliation caught it. The product-master owner should review it.

## KPI snapshot

| KPI | Sep 2017 | vs Aug 2017 | vs Sep 2016 | Target | Status |
|---|---|---|---|---|---|
| Net sales | $976,908 | +1.9% | +12.5% | $894,030 (LY +3%) | On track |
| Gross margin % | 12.1% | −1.1 pts | −1.9 pts | 12.0% | On track |
| Valid orders | 1,640 | −3.2% | −1.4% | – | – |
| Average order value | $595.68 | +5.3% | +14.2% | – | – |
| On-time delivery % | 42.6% | +0.5 pts | −0.3 pts | 50.0% | Off track |
| Cancellation rate % | 4.8% | +0.7 pts | +1.0 pts | 4.0% | Off track |
| Suspected fraud rate % | 2.3% | −0.2 pts | +0.3 pts | 2.0% | Watch |

---

## 1. Sales: a record month, driven by order value

Net sales were $976,908, the highest month in the reporting window, while valid orders fell 3.2% (1,640 vs 1,695). The increase came from **average order value: $595.68, up 5.3% on August and also the highest in the window**.

Gross margin fell 1.1 pts to 12.1%. That still meets the 12.0% target, but only by 0.1 pts. The fall is spread across departments rather than coming from one:

- Fan Shop (48% of sales) fell 1.0 pts, which is the largest effect because of its size.
- Fitness fell 13.3 pts to 4.4%, on products new this month.
- Outdoors fell 4.6 pts and Golf fell 2.0 pts.
- Footwear (+1.3 pts) and Apparel (+0.4 pts) improved.

**Question for Commercial:** is the rise in order value a deliberate mix change, or a one-off? Higher-value orders did not bring a higher margin this month.

## 2. Delivery: the target miss comes from promises on premium modes

| Shipping mode | Valid orders | Promised days | Avg actual days | Late % |
|---|---|---|---|---|
| Same Day | 88 | 0 | 0.63 | 62.5% |
| First Class | 236 | 1 | 2.00 | **100.0%** |
| Second Class | 320 | 2 | 3.98 | **80.6%** |
| Standard Class | 996 | 4 | 3.97 | 39.4% |
| **All modes** | **1,640** | 2.96 | 3.51 | **57.4%** |

- **First Class is late on every order, and has been in every month since January 2015** (8,369 orders). It promises 1 day, and the actual time is 2 days every time.
- **Second Class ships no faster than Standard.** Both average about 4.0 actual days, but Second Class promises 2 days and Standard promises 4.
- **Premium modes drive most of the late orders.** First and Second Class make up 33.9% of valid orders but **52.5% of late orders**.
- **Arithmetic, not a forecast:** if First Class orders had been measured against the 2 days they actually take, September on-time would have been **57.0%**, above target. Re-setting the promise changes the measurement, not what the customer experiences. Whether customers are told "1 day" is the real question.

**Recommendations for Operations:**
1. Confirm what lead time First and Second Class customers are actually promised at checkout.
2. Then either fix the premium carrier service, or re-set the promised days to what the service actually delivers.
3. Review whether premium shipping charges are justified while Second Class performs the same as Standard.

## 3. Cancellations above target

There were 83 cancelled orders out of 1,723 (4.8%): 39 suspected fraud and 44 other cancellations. The rate has been above the 4.0% target in 27 of the 33 months, so the target itself may need review.

**Recommendation:** report fraud and customer cancellations separately in future packs. They have different owners: Finance/Risk for fraud, Customer Service for other cancellations.

## 4. Loss-making products and low-margin categories

Eight products made a loss in September, totalling **−$4,064**:

| Product | Category | Net sales | Gross profit |
|---|---|---|---|
| SOLE E25 Elliptical | Basketball | $1,780 | −$2,520 |
| SOLE E35 Elliptical | Strength Training | $9,780 | −$724 |
| Nike Men's Fingertrap Max Training Shoe | Soccer | $492 | −$322 |
| Merrell Women's Grassbow Sport Hiking Shoe | Men's Golf Clubs | $2,802 | −$318 |
| 4 further products | – | – | −$180 combined |

- **Both elliptical trainers were sold for the first time in September** (they are among 13 products new to the catalogue this month). Together they lost $3,244 on $11,560 of sales.
- Three categories with at least $5,000 of sales were below the 10% margin floor: **Basketball −2.7%, Strength Training −1.6%, Cardio Equipment 8.8%**.
- Discounting does not explain the losses. Across the 33 months, lines with 0–5% discount and lines with 20–25% discount earn the same average profit ratio (about 12%), as recorded in DQ-13.

**Recommendation for Commercial:** check the cost price and pricing set up for the two SOLE ellipticals before more volume goes through at a loss.

## 5. Data note: a new category with mis-mapped products

After the September refresh, check 13 failed by **−$16,234.94**. A category not seen before, **Basketball** (Fitness department), held two children's hybrid bikes and the SOLE E25 elliptical. It was added to the reference list so the pack reconciles, and its figures are reported as supplied.

**Action:** the product-to-category mapping looks wrong and has been logged for the product-master owner (DQ-14). Until it is fixed, category-level figures for Basketball, and for whichever categories these products should belong to, are not reliable.
