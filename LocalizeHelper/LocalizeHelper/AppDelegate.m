//
//  AppDelegate.m
//  LocalizeHelper
//
//  Created by aekschperde on 11.12.14.
//  Copyright (c) 2014 appophil. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
{
    NSString* zielDateiName;
}
- (IBAction)Convert:(id)sender;
- (IBAction)SelectFile:(id)sender;
@property (weak) IBOutlet NSTextField* SelectedFile;
@property (weak) IBOutlet NSWindow* window;
@property (weak) IBOutlet NSMatrix* ConversionType;
@property (unsafe_unretained) IBOutlet NSTextView* Protocol;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
   }

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)Convert:(id)sender
{
    if ([self.SelectedFile stringValue] != nil && ![[self.SelectedFile stringValue] isEqualToString:@""])
    {
        NSString* kommentar;
        NSString* key;
        NSString* wert;
        NSString* quelle;
        NSString* ausgabe = @"";
        if (self.ConversionType.selectedTag == 1)
        {
            [[[self.Protocol textStorage] mutableString] appendString:@"Conversion type: strings to csv.\n"];
            [[[self.Protocol textStorage] mutableString] appendString:@"Analyzing Source file...\n\n"];            
            //wenn zieldatei schon vorhanden, dann fehler in protokoll schreiben und beenden
            zielDateiName = [zielDateiName stringByAppendingString:@".csv"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:zielDateiName])
            {
                quelle = self.SelectedFile.stringValue;
                //wenn quelldatei nicht vorhanden, dann fehler in protokoll schreiben und beenden
                if ([[NSFileManager defaultManager] fileExistsAtPath:quelle])
                {
                    //zieldatei erstellen und zum schreiben öffnen
                    [[NSFileManager defaultManager] createFileAtPath:zielDateiName contents:nil attributes:nil];
                    ausgabe = [ausgabe stringByAppendingString:@"\"Zu uebersetzen\";\"Kommentar\";\"Schluessel\"\n"];
                    
                    //quelldatei öffnen zum lesen
                    NSString* quellinhalt = [NSString stringWithContentsOfFile:quelle encoding:NSUTF8StringEncoding error:nil];
                    NSArray* zeilen = [quellinhalt componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    
                    //gehe über alle zeilen in der datei
                    //leerzeilen ignorieren
                    //wenn kommentar vorhanden, dann kommentar setzen
                    //key setzen
                    //wert setzen
                    BOOL fertig = NO;
                    NSRange range;
                    for (NSString* z in zeilen) {
                        NSString* zeile = [z stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if (![zeile isEqualToString:@""])
                        {
                            if ([[zeile substringToIndex:2] isEqualToString:@"/*"])
                            {
                                //Kommentar
                                kommentar = [[zeile stringByReplacingOccurrencesOfString:@"/*" withString:@""] stringByReplacingOccurrencesOfString:@"*/" withString:@""];
                            }
                            else if ([[zeile substringToIndex:1] isEqualToString:@"\""] && ([zeile containsString:@"\" = \""] || [zeile containsString:@"\"=\""]))
                            {
                                //Key und Wert
                                zeile = [zeile substringFromIndex:1];
                                range.location = 0;
                                range.location = 0;
                                if ([zeile containsString:@"\" = \""])
                                {
                                    range = [zeile rangeOfString:@"\" = \""];
                                    
                                }
                                else if ([zeile containsString:@"\"=\""])
                                {
                                    range = [zeile rangeOfString:@"\"=\""];
                                }
                                if (range.location != 0 && range.length != 0)
                                {
                                    key = [zeile substringToIndex:range.location];
                                    zeile = [zeile substringFromIndex:(range.location + range.length)];
                                }
                                if (zeile.length > 2)
                                {
                                    wert = [zeile substringToIndex:(zeile.length - 2)];
                                    fertig = YES;
                                }
                            }
                           [[[self.Protocol textStorage] mutableString] appendString:[NSString stringWithFormat:@"Analyzing: %@\n",z]];
                        }
                        if (fertig)
                        {
                            ausgabe = [ausgabe stringByAppendingString:[NSString stringWithFormat:@"\"%@\";\"%@\";\"%@\"\n",wert,kommentar,key]];
                            key = @"";
                            wert = @"";
                            kommentar = @"";
                            fertig = false;
                        }
                    }
                    
                    //csv in datei schreiben
                    [ausgabe writeToFile:zielDateiName atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    //fertich
                    [[[self.Protocol textStorage] mutableString] appendString:@"Conversion finished!\n"];
                }
                else
                {
                   [[[self.Protocol textStorage] mutableString] appendString:[NSString stringWithFormat:@"ERROR\nSource file not existing!\n%@\n\n",quelle]];
                }
            }
            else
            {
                [[[self.Protocol textStorage] mutableString] appendString:[NSString stringWithFormat:@"ERROR\nTarget file already existing!\n%@\n\n",zielDateiName]];
            }
        }
        else if (self.ConversionType.selectedTag == 2)
        {
            [[[self.Protocol textStorage] mutableString] appendString:@"Conversion type: csv to string.\n"];
            [[[self.Protocol textStorage] mutableString] appendString:@"Analyzing Source file...\n\n"];
            
            //wenn zieldatei schon vorhanden, dann fehler in protokoll schreiben und beenden
            zielDateiName = [zielDateiName stringByAppendingString:@".strings"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:zielDateiName])
            {
                quelle = self.SelectedFile.stringValue;
                //wenn quelldatei nicht vorhanden, dann fehler in protokoll schreiben und beenden
                if ([[NSFileManager defaultManager] fileExistsAtPath:quelle])
                {
                    //zieldatei erstellen und zum schreiben öffnen
                    [[NSFileManager defaultManager] createFileAtPath:zielDateiName contents:nil attributes:nil];
                    ausgabe = @"";
                    
                    //quelldatei öffnen zum lesen
                    NSString* quellinhalt = [NSString stringWithContentsOfFile:quelle encoding:NSUTF8StringEncoding error:nil];
                    NSArray* zeilen = [quellinhalt componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    int i = 1;
                    //gehe über alle zeilen der quelldatei
                    for (NSString* zeile in zeilen)
                    {
                        //leerzeilen und die titelzeile ignorieren
                        if (i>1)
                        {
                            NSArray* spalten = [zeile componentsSeparatedByString:@";"];
                            if (spalten.count >= 3)
                            {
                                if (![spalten[0] isEqualToString:@""] &&
                                    ![spalten[1] isEqualToString:@""] &&
                                    ![spalten[2] isEqualToString:@""])
                                {
                                    [[[self.Protocol textStorage] mutableString] appendString:[NSString stringWithFormat:@"Analyzing: %@\n",zeile]];
                                    ausgabe = [ausgabe
                                               stringByAppendingString:
                                               [NSString stringWithFormat:@"/* %@ */\n\"%@\" = \"%@\";\n\n",
                                                spalten[1], //kommentar
                                                spalten[2], //key
                                                spalten[0] //wert
                                                ]];
                                }
                            }
                        }
                        i++;
                    }
                    //strings in datei schreiben
                    [ausgabe writeToFile:zielDateiName atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    //fertich
                    [[[self.Protocol textStorage] mutableString] appendString:@"Conversion finished!\n"];
                }
                else
                {
                    [[[self.Protocol textStorage] mutableString] appendString:[NSString stringWithFormat:@"ERROR\nSource file not existing!\n%@\n\n",quelle]];
                }
            }
            else
            {
                [[[self.Protocol textStorage] mutableString] appendString:[NSString stringWithFormat:@"ERROR\nTarget file already existing!\n%@\n\n",zielDateiName]];
            }
           
        }
    }
    else
    {
        [[[self.Protocol textStorage] mutableString] appendString:@"ERROR\nYou must select a valid source file and target directory!\n\n"];
    }
    [self scrollProtocolToEnd];
}

-(void)scrollProtocolToEnd
{
    NSRange range;
    range = NSMakeRange ([[self.Protocol string] length], 0);
    [self.Protocol scrollRangeToVisible: range];
}

- (IBAction)SelectFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            // do something with the url here.
            [self.SelectedFile setStringValue:url.path];
            zielDateiName = [[url path] stringByDeletingPathExtension];
            break;
        }
    }
}

@end
