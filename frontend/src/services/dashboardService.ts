import { smart_labs } from "../utils/axios";
import { dashboard } from "../types/dashboard";

export const dashboardService = {
	getDashboard: () => smart_labs.getAPI<dashboard>("dashboard"),
};
