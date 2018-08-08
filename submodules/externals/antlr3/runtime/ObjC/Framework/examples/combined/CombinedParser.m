/** \file
 *  This OBJC source file was generated by $ANTLR version 3.2 Aug 24, 2010 10:45:57
 *
 *     -  From the grammar source file : Combined.g
 *     -                            On : 2010-08-24 13:53:42
 *     -                for the parser : CombinedParserParser *
 * Editing it, at least manually, is not wise. 
 *
 * ObjC language generator and runtime by Alan Condit, acondit|hereisanat|ipns|dotgoeshere|com.
 *
 *
*/
// [The "BSD licence"]
// Copyright (c) 2010 Alan Condit
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// $ANTLR 3.2 Aug 24, 2010 10:45:57 Combined.g 2010-08-24 13:53:42

/* -----------------------------------------
 * Include the ANTLR3 generated header file.
 */
#import "CombinedParser.h"
/* ----------------------------------------- */


/* ============================================================================= */

/* =============================================================================
 * Start of recognizer
 */



#pragma mark Bitsets
static ANTLRBitSet *FOLLOW_identifier_in_stat20;
static const unsigned long long FOLLOW_identifier_in_stat20_data[] = { 0x0000000000000012LL};
static ANTLRBitSet *FOLLOW_ID_in_identifier35;
static const unsigned long long FOLLOW_ID_in_identifier35_data[] = { 0x0000000000000002LL};


#pragma mark Dynamic Global Scopes

#pragma mark Dynamic Rule Scopes

#pragma mark Rule return scopes start
/* returnScope */

/* returnScope */



@implementation CombinedParser  // line 637

+ (void) initialize
{
    #pragma mark Bitsets
    FOLLOW_identifier_in_stat20 = [[ANTLRBitSet newANTLRBitSetWithBits:(const unsigned long long *)FOLLOW_identifier_in_stat20_data Count:(NSUInteger)1] retain];
    FOLLOW_ID_in_identifier35 = [[ANTLRBitSet newANTLRBitSetWithBits:(const unsigned long long *)FOLLOW_ID_in_identifier35_data Count:(NSUInteger)1] retain];

    [ANTLRBaseRecognizer setTokenNames:[[[NSArray alloc] initWithObjects:@"<invalid>", @"<EOR>", @"<DOWN>", @"<UP>", 
 @"ID", @"INT", @"WS", nil] retain]];
}

+ (CombinedParser *)newCombinedParser:(id<ANTLRTokenStream>)aStream
{
    return [[CombinedParser alloc] initWithTokenStream:aStream];

}

- (id) initWithTokenStream:(id<ANTLRTokenStream>)aStream
{
    if ((self = [super initWithTokenStream:aStream State:[[ANTLRRecognizerSharedState newANTLRRecognizerSharedStateWithRuleLen:2+1] retain]]) != nil) {



        /* start of actions-actionScope-init */
        /* start of init */
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}
// start actions.actionScope.methods
// start methods()
// start rules
/*
 * $ANTLR start stat
 * Combined.g:7:1: stat : ( identifier )+ ;
 */
- (void) stat
{
    /* ruleScopeSetUp */

    @try {
        // Combined.g:7:5: ( ( identifier )+ ) // ruleBlockSingleAlt
        // Combined.g:7:7: ( identifier )+ // alt
        {
        // Combined.g:7:7: ( identifier )+ // positiveClosureBlock
        NSInteger cnt1=0;
        do {
            NSInteger alt1=2;
            NSInteger LA1_0 = [input LA:1];
            if ( (LA1_0==ID) ) {
                alt1=1;
            }


            switch (alt1) {
                case 1 : ;
                    // Combined.g:7:7: identifier // alt
                    {
                    [self pushFollow:FOLLOW_identifier_in_stat20];
                    [self identifier];
                    [self popFollow];

                      /* element() */
                     /* elements */
                    }
                    break;

                default :
                    if ( cnt1 >= 1 )
                        goto loop1;
                    ANTLREarlyExitException *eee = [ANTLREarlyExitException exceptionWithStream:input decisionNumber:1];
                    @throw eee;
            }
            cnt1++;
        } while (YES);
        loop1: ;
          /* element() */
         /* elements */
        }

        // token+rule list labels

    }
    @catch (ANTLRRecognitionException *re) {
        [self reportError:re];
        [self recover:input Exception:re];
    }    @finally {
    }
    return ;
}
/* $ANTLR end stat */
/*
 * $ANTLR start identifier
 * Combined.g:9:1: identifier : ID ;
 */
- (void) identifier
{
    /* ruleScopeSetUp */

    @try {
        // Combined.g:10:5: ( ID ) // ruleBlockSingleAlt
        // Combined.g:10:7: ID // alt
        {
        [self match:input TokenType:ID Follow:FOLLOW_ID_in_identifier35];   /* element() */
         /* elements */
        }

        // token+rule list labels

    }
    @catch (ANTLRRecognitionException *re) {
        [self reportError:re];
        [self recover:input Exception:re];
    }    @finally {
    }
    return ;
}
/* $ANTLR end identifier */

@end /* end of CombinedParser implementation line 692 */


/* End of code
 * =============================================================================
 */
