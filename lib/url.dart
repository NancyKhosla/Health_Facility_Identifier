const BASE_URL = 'https://cdashboard.dcservices.in/';

const state_List = BASE_URL +
    'HISUtilities/services/restful/GenericProcessesDataWebService/getDataService/GetStateForCoordinateCapture';
const Facility_List = BASE_URL +
    'HISUtilities/services/restful/GenericProcessesDataWebService/getDataService/GetFacTypeForCoordinateCapture';

const store_List = BASE_URL +
    'HISUtilities/services/restful/GenericProcessesDataWebService/getDataService/GetStoreForCoordinateCapture';

const save_cordinates = BASE_URL +
    'HISUtilities/services/restful/EMMSComplaintDataWebService/DMLService/dml_state_store_mst_geo_coordinate';
