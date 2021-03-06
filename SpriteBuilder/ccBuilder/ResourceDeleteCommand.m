#import "ResourceDeleteCommand.h"

#import "SCEventListenerProtocol.h"
#import "ResourceManager.h"
#import "RMPackage.h"
#import "RMResource.h"
#import "ProjectSettings.h"
#import "PackageRemover.h"
#import "NSAlert+Convenience.h"

@implementation ResourceDeleteCommand

- (void)execute
{
    NSAssert(_projectSettings != nil ,@"Project settings must not be nil");
    NSAssert(_outlineView != nil ,@"OutlineView should be set");

    if (!_resources
        || _resources.count == 0
        || ![self askUserForConfirmation])
    {
        return;
    }

    NSMutableArray *resourcesToDelete = [[NSMutableArray alloc] init];
    NSMutableArray *foldersToDelete = [[NSMutableArray alloc] init];
    NSMutableArray *packagesPathsToDelete = [[NSMutableArray alloc] init];

    [self sortItemsToDeleteIntoArrays:resourcesToDelete
                      foldersToDelete:foldersToDelete
                packagesPathsToDelete:packagesPathsToDelete];

    if ([self willAllPackagesBeDeleted:packagesPathsToDelete])
    {
        [NSAlert showModalDialogWithTitle:@"Error" message:@"At least one package must remain in the project."];
        return;
    }

    [self deleteResourcesInArrays:resourcesToDelete
                  foldersToDelete:foldersToDelete
            packagesPathsToDelete:packagesPathsToDelete];

    [_outlineView deselectAll:nil];

    [_resourceManager reloadAllResources];
}

- (BOOL)willAllPackagesBeDeleted:(NSArray *)packagePathsToDelete
{
    if(packagePathsToDelete.count == 0)
        return 0;
    
    NSArray *packages = [_resourceManager allPackages];

    return packagePathsToDelete.count > packages.count;
}

- (void)deleteResourcesInArrays:(NSMutableArray *)resourcesToDelete
                foldersToDelete:(NSMutableArray *)foldersToDelete
          packagesPathsToDelete:(NSMutableArray *)packagesPathsToDelete
{
    for (RMResource *res in resourcesToDelete)
    {
        [ResourceManager removeResource:res];
    }

    for (RMResource *res in foldersToDelete)
    {
        [ResourceManager removeResource:res];
    }

    PackageRemover *packageRemover = [[PackageRemover alloc] init];
    packageRemover.projectSettings = _projectSettings;
    [packageRemover removePackagesFromProject:packagesPathsToDelete error:NULL];
}

- (void)sortItemsToDeleteIntoArrays:(NSMutableArray *)resourcesToDelete
                    foldersToDelete:(NSMutableArray *)foldersToDelete
              packagesPathsToDelete:(NSMutableArray *)packagesPathsToDelete
{
    for (id resource in _resources)
    {
        if ([resource isKindOfClass:[RMResource class]])
        {
            RMResource *aResource = (RMResource *) resource;
            if (aResource.type == kCCBResTypeDirectory)
            {
                [foldersToDelete addObject:resource];
            }
            else
            {
                [resourcesToDelete addObject:resource];
            }
        }
        else if ([resource isKindOfClass:[RMPackage class]])
        {
            RMPackage *rmDirectory = (RMPackage *) resource;
            [packagesPathsToDelete addObject:rmDirectory.dirPath];
        }
    }
}

- (BOOL)askUserForConfirmation
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Are you sure you want to delete the selected files?"
                                     defaultButton:@"Cancel"
                                   alternateButton:@"Delete"
                                       otherButton:NULL
                         informativeTextWithFormat:@"You cannot undo this operation."];

    NSInteger result = [alert runModal];

    return result != NSAlertDefaultReturn;
}


#pragma mark - ResourceCommandContextMenuProtocol

+ (NSString *)nameForResources:(NSArray *)resources
{
    return @"Delete";
}

+ (BOOL)isValidForSelectedResources:(NSArray *)resources
{
    return ([resources.firstObject isKindOfClass:[RMResource class]]
            || (resources.count > 0)
            || [resources.firstObject isKindOfClass:[RMPackage class]]);
}


@end
