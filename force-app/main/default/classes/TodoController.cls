public with sharing class TodoController {

    public class Filters {
        @AuraEnabled
        public String searchKey { get; set; }

        @AuraEnabled
        public String[] types { get; set; }

        @AuraEnabled
        public String[] priorities { get; set; }

        @AuraEnabled
        public String sortBy { get; set; }
    }

    @AuraEnabled(Cacheable=true scope='global')
    public static TodoCardListData getTodoData(Filters filters, Integer pageSize, Integer pageNumber) {
        String key = '';
        String whereClause = '';
        String sortByString = '';
        String[] types, priorities, criteria = new List<String>{};

        if (filters != null) {
            types = filters.types;
            priorities = filters.priorities;
            sortByString = filters.sortBy;

            if (!String.isEmpty(filters.searchKey)) {
                key = '%' + filters.searchKey + '%';
                criteria.add('Name LIKE :key');
            }
            if (filters.types != null) {
                types = filters.types;
                criteria.add('Type__c IN :types');
            }
            if (filters.priorities != null) {
                priorities = filters.priorities;
                criteria.add('Priority__c IN :priorities');
            }

            if (criteria.size() > 0) {
                whereClause = 'WHERE ' + String.join(criteria, ' AND ');
            }
        }

        Integer offset = (pageNumber - 1) * pageSize;

        TodoCardListData result = new TodoCardListData();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        result.totalItemCount = Database.countQuery('SELECT COUNT() FROM To_Do__c ' + whereClause);
        result.records = Database.query(
            'SELECT Id, Name, Type__c, Priority__c, Due_Date__c, Description__c, Completed__c FROM To_Do__c ' +
            whereClause +
            ' ORDER BY '+sortByString+' LIMIT :pageSize OFFSET :offset'
        );
        return result;
    }
}