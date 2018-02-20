//
//  AKStorage.m
//  test1
//
//  Created by MacJenkins on 16/02/2018.
//  Copyright © 2018 Aaron Zhang. All rights reserved.
//

#import "AKStorage.h"
#import "AKLog.h"
#import <sqlite3.h>

#define DBNAME    @"AKStorage.sqlite"
#define KEY       @"key"
#define DATA      @"data"
#define DUEDATE   @"due_date"
#define TABLENAME @"AKStorage"

@implementation AKStorage
{
    sqlite3 *db;
    sqlite3_stmt *stmtInst, *stmtQuery, *stmtDelete;
}

-(instancetype)init
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
    
    if (sqlite3_open_v2([database_path UTF8String], &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
             | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_SHAREDCACHE, NULL) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库打开失败");
        return self;
    }
    if ([self dbInitialize])
    {
        NSString *str = @"test vavdsa122";
        [self dbSaveWithKey:@"fdsdf" value:[str dataUsingEncoding:NSUTF8StringEncoding] dueDate:2];
        NSData* dd = [self dbValueForKey:@"fdsdf"];
        str = [[NSString alloc] initWithData: dd encoding:NSUTF8StringEncoding];
        NSLog(str);
    }

    [self dbClose];
    return self;
}
-(BOOL)dbExec:(NSString*)sql
{
    return sqlite3_exec(db, [sql UTF8String], NULL, NULL, NULL) == SQLITE_OK;
}

- (BOOL)dbInitialize {
 
    NSString *sql = [NSString stringWithFormat: @"pragma journal_mode = wal; pragma synchronous = normal; create table if not exists %@ (%@ text PRIMARY KEY, %@ blob,%@ integer);", TABLENAME, KEY, DATA, DUEDATE];
    //ID INTEGER PRIMARY KEY AUTOINCREMENT
    if (![self dbExec:sql]) {
        return false;
    }
    
    // Prepare statements
    sql = [NSString stringWithFormat: @"insert or replace into %@ (%@, %@, %@) values (?1, ?2, ?3);", TABLENAME, KEY, DATA, DUEDATE];
    stmtInst = [self dbPrepareStmt:sql];
    sql = [NSString stringWithFormat:@"SELECT data FROM %@ WHERE key = ?",TABLENAME];
    stmtQuery= [self dbPrepareStmt:sql];
    sql = [NSString stringWithFormat:@"delete from %@ where key = ?;",TABLENAME];
    stmtDelete= [self dbPrepareStmt:sql];
    return true;
}

-(void)dbClose {
    
    // Clear statements
    sqlite3_stmt *stmt;
    while ((stmt = sqlite3_next_stmt(db, nil)) != 0) {
        sqlite3_finalize(stmt);
    }
    
    sqlite3_close(db);
}

- (sqlite3_stmt *)dbPrepareStmt:(NSString*)sql {
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(db));
    }

    return stmt;
}

- (BOOL)dbSaveWithKey:(NSString *)key value:(NSData *)value dueDate:(NSInteger)days{
    sqlite3_stmt *stmt = stmtInst;
    if (!stmt) return NO;

    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    sqlite3_bind_blob(stmt, 2, [value bytes], (int)value.length, NULL);
    sqlite3_bind_int(stmt, 3, (int)(time(NULL) + days * 86400));

    int result = sqlite3_step(stmt);
    
    sqlite3_reset(stmt);
    sqlite3_clear_bindings(stmt);
    
    if (result != SQLITE_DONE) {
        NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(db));
        return NO;
    }
    
    return YES;
}

- (BOOL)dbDeleteItemWithKey:(NSString *)key {

    sqlite3_stmt *stmt = stmtDelete;
    if (!stmt) return NO;
    
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    int result = sqlite3_step(stmt);
    
    sqlite3_reset(stmt);
    sqlite3_clear_bindings(stmt);
    
    if (result != SQLITE_DONE) {
        NSLog(@"%s line:%d db delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(db));
        return NO;
    }
    return YES;
}

- (NSData *)dbValueForKey:(NSString *)key{
    sqlite3_stmt *stmt = stmtQuery;
    if (!stmt) return NO;
    
    NSData* data = nil;

    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        const void *bytes = (void*)sqlite3_column_blob(stmt, 0);
        int size = sqlite3_column_bytes(stmt, 0);
        //int date = sqlite3_column_int(statement, 2);
        data = [[NSData alloc]initWithBytes:bytes length:size];
    }
    sqlite3_reset(stmt);
    sqlite3_clear_bindings(stmt);

    return data;
}
@end
