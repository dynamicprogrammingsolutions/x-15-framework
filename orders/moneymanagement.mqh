#include "moneymanagement/processor_moneymanagement.mqh"
#include "moneymanagement/mm_fixed.mqh"

#define REGISTER_MONEY_MANAGEMENT_FILTER RegisterMoneyManagementOrderFilters();

void RegisterMoneyManagementOrderFilters() {
   RegisterOrderProcessor(OrderProcessorMoneyManagement);
}
