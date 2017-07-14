//
//  RunInferenceOperation.m
//  LibTensorFlowForiOSSwift
//
//  Created by 邵伟男 on 2017/7/13.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import "RunInferenceOperation.h"

#include <fstream>
#include <pthread.h>
#include <unistd.h>
#include <queue>
#include <sstream>
#include <string>

#include "tensorflow/core/framework/op_kernel.h"
#include "tensorflow/core/public/session.h"


@implementation EmojiValue

- (instancetype)initWithEmojiString:(NSString *)emoji
                         confidence:(float)confidence {
    self = [super init];
    if (self) {
        self.emoji = emoji;
        self.confidence = confidence;
    }
    return self;
}


+ (instancetype)emojiValueWithEmojiString:(NSString *)emoji
                               confidence:(float)confidence{
    return [[self.class alloc] initWithEmojiString:emoji confidence:confidence];
}

@end


namespace {
    class IfstreamInputStream : public ::google::protobuf::io::CopyingInputStream {
    public:
        explicit IfstreamInputStream(const std::string& file_name)
        : ifs_(file_name.c_str(), std::ios::in | std::ios::binary) {}
        ~IfstreamInputStream() { ifs_.close(); }
        
        int Read(void* buffer, int size) {
            if (!ifs_) {
                return -1;
            }
            ifs_.read(static_cast<char*>(buffer), size);
            return (int)ifs_.gcount();
        }
        
    private:
        std::ifstream ifs_;
    };
}  // namespace

std::vector<std::pair<std::string, float>> RunInference(const std::string& sent);
void InitModel();

tensorflow::Session* session_pointer = nullptr;
std::unique_ptr<tensorflow::Session> session;
static bool isInitModel = false;

static RunInferenceOperation *__staticInstance;

@interface RunInferenceOperation() <NSCopying>

@end

@implementation RunInferenceOperation

#pragma mark: Shared Instance
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __staticInstance = [[self.class alloc] init];
    });
    return __staticInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __staticInstance = [super allocWithZone:zone];
    });
    return __staticInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"init RunInferenceOperation");
        });
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return __staticInstance;
}


#pragma mark: TensorFlow Init Model
- (void)initModel {
    if (!isInitModel) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isInitModel = true;
            InitModel();
        });
    }
}

#pragma mark: TensorFlow Run Model
- (NSArray<EmojiValue *> *)runModelWith:(NSString *)string {
    if (string.length <= 0) {
        return nil;
    }
    
    std::string sent([string UTF8String]);
    if (sent.empty()) {
        return nil;
    }
    
    auto predict = RunInference(sent);
    
    NSMutableArray<EmojiValue *> *result = [NSMutableArray array];
    
    for (const auto& tuple : predict) {
        const std::string& emoji = tuple.first;
        const float confidenceScore = tuple.second;
        
        NSString *emojiString = [NSString stringWithUTF8String: emoji.c_str()];
        EmojiValue *value = [EmojiValue emojiValueWithEmojiString:emojiString
                                                       confidence:confidenceScore];
        [result addObject:value];
    }
    return result;
}

@end


#pragma mark: TensorFlow
NSString* FilePathForResourceName(NSString* name, NSString* extension) {
    NSString* file_path = [[NSBundle mainBundle] pathForResource:name ofType:extension];
    if (file_path == NULL) {
        LOG(FATAL) << "Couldn't find '" << [name UTF8String] << "."
        << [extension UTF8String] << "' in bundle.";
    }
    return file_path;
}

bool PortableReadFileToProto(const std::string& file_name,
                             ::google::protobuf::MessageLite* proto) {
    ::google::protobuf::io::CopyingInputStreamAdaptor stream(
                                                             new IfstreamInputStream(file_name));
    stream.SetOwnsCopyingStream(true);
    // TODO(jiayq): the following coded stream is for debugging purposes to allow
    // one to parse arbitrarily large messages for MessageLite. One most likely
    // doesn't want to put protobufs larger than 64MB on Android, so we should
    // eventually remove this and quit loud when a large protobuf is passed in.
    ::google::protobuf::io::CodedInputStream coded_stream(&stream);
    // Total bytes hard limit / warning limit are set to 1GB and 512MB
    // respectively.
    coded_stream.SetTotalBytesLimit(1024LL << 20, 512LL << 20);
    return proto->ParseFromCodedStream(&coded_stream);
}

std::vector<std::string> label_strings = {
    "🎉", "🎈", "🙊", "🙄", "👑", "✨", "💞", "💕", "❤", "😏", "🔥", "😎", "💀",
    "😂", "😍", "😊", "😈", "❤️", "💔", "😅", "🌟", "😜", "😭", "💗", "😋", "🌹",
    "😩", "💦", "♂",  "🙏", "☺",  "💯", "😆", "➡️", "🙌", "💜", "✔",  "💓", "💙",
    "😀", "👉", "😬", "👌", "😘", "♡", "🙃", "😁", "🙂", "👀", "💃", "💛", "👏",
    "👍", "😛", "💪", "💋", "😻", "😉", "😄", "😴", "💥", "💖", "😤", "🚨", "⚡",
    "😳", "🎶", "🗣", "👅", "😫", "✌",  "💚", "🙈", "😇", "😒", "😌", "❗", "😢",
    "😕", "👊", "🌙", "👇", "😔", "❄",  "💘", "✊", "💫", "😡", "♀",  "🏆", "🌸",
    "★", "😱", "📷",  "💰", "⚽", "🐐", "✅"
};

void InitModel() {
    tensorflow::SessionOptions options;
    options.config.mutable_graph_options()
        ->mutable_optimizer_options()
        ->set_opt_level(tensorflow::OptimizerOptions::L0);
    options.config.set_inter_op_parallelism_threads(1);
    options.config.set_intra_op_parallelism_threads(1);
    tensorflow::Status session_status = tensorflow::NewSession(options, &session_pointer);
    
    if (!session_status.ok()) {
        std::string status_string = session_status.ToString();
        NSLog(@"Session create failed - %s", status_string.c_str());
        return;
    }
    session.reset(session_pointer);
    LOG(INFO) << "Session created.";
    
    tensorflow::GraphDef tensorflow_graph;
    LOG(INFO) << "Graph created.";
    
    NSString* network_path = FilePathForResourceName(@"emoji_frozen", @"pb");  // tensorflow_inception_graph
    PortableReadFileToProto([network_path UTF8String], &tensorflow_graph);
    
    LOG(INFO) << "Creating session.";
    tensorflow::Status s = session->Create(tensorflow_graph);
    if (!s.ok()) {
        LOG(ERROR) << "Could not create TensorFlow Graph: " << s;
        return;
    }
    
}

// Generates feature sequence for a sentence.
tensorflow::Tensor TextToInputSequence(const std::string& sent) {
    // Everything here should be consistent with the original Python code (tokenize_dataset.ipynb).
    // Magic alphabet and label_strings are come from.
    tensorflow::Tensor text_tensor(tensorflow::DT_INT32, tensorflow::TensorShape({1, 120}));
    auto tensor_mapped = text_tensor.tensor<tensorflow::int32, 2>();
    tensorflow::int32* data = tensor_mapped.data();
    
    // num_alphabet = 36  # (3+33)
    // num_cat = 99 # (1+98)
    // T_PAD = 0
    // T_OOV = 2
    const int T_START = 1;
    
    // Build alphabet.
    std::string alphabet = "### eotainsrlhuydmgwcpfbk.v'!,jx?zq_";
    std::map<char, int> aidx;
    for (int i = 0; i < alphabet.length(); ++i) {
        aidx[alphabet[i]] = i;
    }
    // Generate seq.
    std::vector<int> seq;
    seq.push_back(T_START);
    for (char ch : sent) {
        char lower_ch = tolower(ch);
        if (aidx.count(lower_ch) > 0) {
            seq.push_back(aidx[lower_ch]);
        }
    }
    // Trim and padding.
    const int MAX_LEN = 120;
    int seq_len = std::min(MAX_LEN, (int)seq.size());
    memset(data, 0, MAX_LEN * sizeof(int));
    memcpy(data + (MAX_LEN - seq_len), seq.data(), seq_len * sizeof(int));
    
    return text_tensor;
}


// Returns the top N confidence values over threshold in the provided vector,
// sorted by confidence in descending order.
static void GetTopN(
                    const Eigen::TensorMap<Eigen::Tensor<float, 1, Eigen::RowMajor>,
                    Eigen::Aligned>& prediction,
                    const int num_results, const float threshold,
                    std::vector<std::pair<float, int> >* top_results) {
    // Will contain top N results in ascending order.
    std::priority_queue<std::pair<float, int>,
    std::vector<std::pair<float, int> >,
    std::greater<std::pair<float, int> > > top_result_pq;
    
    const int count = (int)prediction.size();
    for (int i = 0; i < count; ++i) {
        const float value = prediction(i);
        
        // Only add it if it beats the threshold and has a chance at being in
        // the top N.
        if (value < threshold) {
            continue;
        }
        
        top_result_pq.push(std::pair<float, int>(value, i));
        
        // If at capacity, kick the smallest value out.
        if (top_result_pq.size() > num_results) {
            top_result_pq.pop();
        }
    }
    
    // Copy to output vector and reverse into descending order.
    while (!top_result_pq.empty()) {
        top_results->push_back(top_result_pq.top());
        top_result_pq.pop();
    }
    std::reverse(top_results->begin(), top_results->end());
}

std::vector<std::pair<std::string, float>> RunInference(const std::string& sent) {
    std::vector<std::pair<std::string, float>> inference_result;
    // Extract feature.
    auto text_tensor = TextToInputSequence(sent);
    // Inference.
    std::string input_layer = "input_1";
    std::string output_layer = "dense_2/Softmax";
    std::vector<tensorflow::Tensor> outputs;
    tensorflow::RunOptions options;
    tensorflow::RunMetadata metadata;
    tensorflow::Status run_status = session->Run(
                                                 {{input_layer, text_tensor}}, {output_layer}, {}, &outputs);
    if (!run_status.ok()) {
        LOG(ERROR) << "Running model failed: " << run_status;
        tensorflow::LogAllRegisteredKernels();
        return inference_result;
    }
    tensorflow::string status_string = run_status.ToString();
    LOG(INFO) << "Run status: " << status_string;
    
    // Collect outputs.
    tensorflow::Tensor* output = &outputs[0];
    const int kNumResults = 20;
    const float kThreshold = 0.005f;
    std::vector<std::pair<float, int>> top_results;
    GetTopN(output->flat<float>(), kNumResults, kThreshold, &top_results);
    
    std::stringstream ss;
    ss.precision(3);
    for (const auto& result : top_results) {
        const float confidence = result.first;
        const int index = result.second;
        const std::string& label = label_strings[index];
        ss << index << " " << confidence << "  " << label << "\n";
        inference_result.emplace_back(label, confidence);
    }
    LOG(INFO) << "Predictions: " << ss.str();
    return inference_result;
}
